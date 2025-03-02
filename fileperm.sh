#!/bin/bash

# For file/directory permissions we need:
# 1. file/directory name which can be 1 option and argument
# 2. user or group name that is having permissions updated or being set as owner

# Function to display script usage/help information
function display_usage() {
  echo "Usage: 
            fileperm.sh -f <filen or directory path> -n <user or group name> -a <action>"
  echo "options:"
  echo "-f <filename or directory>: Specify the relative or absolute file or directory path."
  echo "-n <user of group name>: Specify the user or group"
  echo "-a <action>: Specify action to perform. Supported actions are 'owner' and 'permission'."
  echo "If action is 'permission', input permissions must 'r,w,x,d'. Example: Read = r, Write Execute = wx, Deny = d"
  echo "-h: Display help information about the script and its usage."
}

# Check if no arguments are provided.
# If so, display usage information and exit
if [[ $# -eq 0 || "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# Initialize variables
fileordirname=""
userorgroupname=""
action=""

# Process command-line options and arguments
while getopts ":f:n:a:h" opt; do
    case $opt in
        # option f
        f)
            fileordirname=$OPTARG
        ;;
        # option n
        n)
            userorgroupname=$OPTARG
        ;;
        # option o
        a)
            action=$OPTARG
        ;;
        # option h
        # display usage and exit
        h)
            display_usage
            exit 0
        ;;
        # any other option
        \?)
            echo "Invalid option: $OPTARG"
            # display usage and exit
            display_usage
            exit 1
        ;;
        # no argument
        :)
            echo "Option $OPTARG requires an argument."
            # display usage and exit
            display_usage
            exit 1
        ;;
    esac
done
# Check if all required switches are provided (f, n, a are required)
    if [[ -z $fileordirname || -z $userorgroupname || -z $action ]]; then
        echo "Error: Missing required options."
        # display usage and exit
        display_usage
        exit 1
    fi

# Check if the -a switch has a valid argument
    if [[ $action != "owner" && $action != "permission" ]]; then
        echo "Error: Invalid action type. Supported types are 'owner' and 'permission'."
        # exit
        exit 1
    fi

# Check if the specified input file or directory exists and is a regular file or directory
    if [ -e "$fileordirname" ]; then
        if [ -f "$fileordirname" ]; then
            :
        elif [ -d "$fileordirname" ]; then
            :
        else
            echo "Error: $fileordirname exists, but it's neither a regular file nor directory"
            exit 1
        fi
    else
        echo "$fileordirname does not exist"
        exit 1
    fi
     
#Check if specified user exists
    if id "$userorgroupname" &>/dev/null || getent group "$userorgroupname" &>/dev/null; then
        :
    else
        echo "Error: User or group does not exist."
        exit 1
    fi

# Time to perform the specified action
# Need to try and figure out how to get full path of file or directory so that chown works
# Also need to complete the permission action
    if [[ $action == "owner" ]]; then
        chown $userorgroupname $fileordirname 2>/dev/null
            # Check if setting user acl fails
            if [ $? -ne 0 ]; then
                # Set group acl if user acl fails and hide the user command failing
                chgrp $userorgroupname $fileordirname &>/dev/null
            fi
    elif [[ $action == "permission" ]]; then
        # Have user input permissions to be set
        read -p "Enter the permissions for $userorgroupname: " perms
        # Check if perms is valid or set to deny
        if [[ ! $perms == "r" || ! $perms == "rw" || ! $perms == "rwx" || ! $perms == "rx" || ! $perms =="w" || 
              ! $perms == "wx" || ! $perms == "x" || ! $perms == "d" ]]; then
            echo "Error: permissions are not formatted properly."
            exit 1
        fi
        # If permissions are set then update the ACL of file or directory
        if [[ $perms =~ (r|rw|rwx|rx|w|wx|x) ]]; then
            setfacl -m u:$userorgroupname:$perms $fileordirname 2>/dev/null
            # Check if setting user acl fails
            if [ $? -ne 0 ]; then
                # Set group acl if user acl fails and hide the user command failing
                setfacl -m g:$userorgroupname:$perms $fileordirname &>/dev/null
            fi
        # If deny is input then run command to remove user/group from ACL of file/directory
        elif [[ $perms =~ (d) ]]; then
            setfacl -x u:$userorgroupname $fileordirname 2>/dev/null
            # Check if removing user acl fails
            if [ $? -ne 0 ]; then
                # Remove group acl if user acl fails and hide the user command failing
                setfacl -x g:$userorgroupname $fileordirname &>/dev/null
            fi
        fi
    fi