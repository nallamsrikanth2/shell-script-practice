#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$( date +%/F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
    echo -e "$R plese run the root user $N"
    exit 1
else
    echo -e "$G you are in root server"
fi

VALIDATE (){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 ... Failue $N"
        exit 1
    else
        echo -e "$G $2 ... success $N"
    fi
}

dnf install nginx -y 
VALIDATE $? "install the nginx"

systemctl enable nginx
VALIDATE $? "enable the nginx"

systemctl start nginx
VALIDATE $? "start the nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "remove everything in html directory"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "download the frontend code"

cd /usr/share/nginx/html
VALIDATE $? "move to html"

unzip /tmp/frontend.zip
VALIDATE $? "unzip the code"

cp /home/ec2-user/shell-script-practice/expense.conf   /etc/nginx/default.d/expense.conf
VALIDATE $? "copy the code"

systemctl restart nginx
VALIDATE $? "restart the nginx"

