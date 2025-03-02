# bash-project-spring-25-clark4de-git

Intro

This script's purpose is to assist in setting permissions for a user or group on a single file or directory. These permissions are set on the file or directory's ACL and specifies the permissions that the user or group will have independent of the current Owner:Group:Everyone permissions set on the file or directory. It also allows you to set a user or group as the owner of a file or directory as well.

Documentation

There are two main features of this script and those are setting ownership "owner" and setting permissions "permission". The usage of this script is as follows: fileperm.sh -f <file or directory path> -n <user or group name> -a <action>. All arguements are required and the two supported actions and main features are "owner" and "permission". The full or relative file/directory path are needed to set permissions and change ownership outside of the current working directory.

When utilizing the "permission" action you will be asked to input the permissions you want to set on your specified file or directory. specific syntax is needed for this input and examples are as follows: Read = r , Execute and Write = wx , Deny = d. 
