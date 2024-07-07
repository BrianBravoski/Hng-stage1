#!/bin/bash

## Check whether the script is run as sudo
if (("$UID" != 0));
then 
    echo "script requires root priviledge"
    exit 1
fi


##check if the file is provided
if [ -z "$1"]; then
    echo "Error: No file was provided"
    exit 1
fi

## list of all the funtions 
# Read and parse the input file
read_text_file(){
    local filename="$1"
    while IFS=';' read -r user groups; do
        users+=("$(echo "$user" | xargs)")
        group_list+=("$(echo "$groups" | xargs)")
    done < "$filename"
}



#Create a user and a group with the same name
create_user_and_group(){
    local username="$1"
    if id "$username" &>/dev/null; then
        echo "User $username already exists." | tee -a "$LOG_FILE"
    else
        groupadd "$username"
        useradd -m -g  "$username" -s /bin/bash "$username"
        echo "Created user $username and created group $username." | tee -a "$LOG_FILE"
    fi 
}

## Setting a password for the user
set_password(){
    local username="$1"
    local password=$(openssl rand -base64 8)
    echo "$username:$password" | chpasswd
    echo "$username:$password" >> "$PASSWORD_FILE"
    echo "password for $username created and stored in $PASSWORD_FILE." | tee -a "$LOG_FILE"
}


## Add users to the groups
add_users_groups(){
    local username="$1"
    IFS=',' read -r -a groups <<< "$2"
  for group in "${groups[@]}"; do
    if ! getent group "$group" &>/dev/null; then
      groupadd "$group"
      echo "Group $group created." | tee -a "$LOG_FILE"
    fi
    usermod -aG "$group" "$username"
    echo "Added $username to group $group." | tee -a "$LOG_FILE"
  done
}


#Variables
INPUT_FILE="$1"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"
declare -a users
declare -a group_list


## Create the log and password files
mkdir -p /var/log /var/secure
touch "$LOG_FILE"
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"


## read the text file 
read_text_file "$INPUT_FILE"

## loop through all users and create users
for ((i = 0; i < ${#users[@]}; i++)); do
  username="${users[i]}"
  user_groups="${group_list[i]}"

  if [[ "$username" == "" ]]; then
    continue  # Skip empty usernames
  fi

  create_user_and_group "$username"
  set_password "$username"
  add_users_groups "$username" "$user_groups"
done

echo "Users created and group assignment completed." | tee -a "$LOG_FILE"