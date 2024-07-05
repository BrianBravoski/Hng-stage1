# Hng-stage1
This is a Linux bash script that does the following:

1. reads a file which contains a user and group
2. Creates the users and groups
3. checks whether there is an existing user and skips
4. adds a user to the specified group and create a group with the user's name
5. Randomly generates passwords for the created users and save them in 
    - /var/log/user_management.log
6. create a log file of all the things that the script performs.
    - /var/secure/user_passwords.csv
7. 
