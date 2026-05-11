#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "enter your password"
read -s password

if [ $USERID -ne 0 ]
then 
    echo -e "$R please run the root user $N"
    exit 1
else
    echo -e "$G you are a root user $N"
fi

VALIDATE (){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 ... failure $N"
        exit 1
    else
        echo -e "$G $2 ... success $N"
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "install the mysql-server"

systemctl enable mysqld   &>>$LOG_FILE
VALIDATE $? "enable the mysqld"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "start the mysqld"


mysql -h db.nsrikanth.online -uroot -p"${password}" -e 'show databases;'  &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass "${password}" &>>$LOG_FILE
    VALIDATE $? "set up the root password" 
else
    echo -e "$Y root password already set up ...Skipping $N"
fi