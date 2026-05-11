#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R FAILURE $N"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

echo "Script started at $TIMESTAMP" &>>$LOGFILE

# Root check
if [ $USERID -ne 0 ]
then
    echo -e "$R Please run as root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

# NodeJS setup
dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disable NodeJS module"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable NodeJS:20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Install NodeJS"

# Create user
id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "$Y User already exists $N"
fi

# App setup
mkdir -p /app &>>$LOGFILE
VALIDATE $? "Create /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Download backend code"

cd /app &>>$LOGFILE
VALIDATE $? "Change directory to /app"

rm -rf /app/* &>>$LOGFILE

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzip backend code"

# Install dependencies
npm install &>>$LOGFILE
VALIDATE $? "Install NodeJS dependencies"

# Systemd service
cp /home/ec2-user/shell-script-practice/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copy backend.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Start backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enable backend"

# MySQL client
dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Install MySQL client"

# Load schema
mysql -h db.nsrikanth.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Load schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restart backend"

echo -e "$G Backend setup completed successfully $N"