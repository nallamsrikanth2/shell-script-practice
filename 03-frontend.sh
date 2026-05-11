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