USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$TIMESTAMP-$SCRIPT_NAME.log


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "enter the password"
read -s password

if [ $USERID -ne 0 ]
then
    echo -e "$R please run the root user"
    exit 1
else
    echo -e "$G you are a root user $N"
fi


VALIDATE (){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 ... Failure $N"
        exit 1
    else
        echo -e "$G $2 ... Success $N"
    fi

}

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "disable the nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable nodejs"

dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "install the node js"

id expense
if [ $? -ne 0 ]
then
    useradd expense   &>>$LOG_FILE
    VALIDATE $? "create the user"
else
    echo -e "$Y alredy user created $N"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "creating  the app directory"

rm -rf /app/*  &>>$LOG_FILE
VALIDATE $? "remove everything in app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE
VALIDATE $? "download the backend code"

cd /app &>>$LOG_FILE
VALIDATE $? "move  to app"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"


npm install  &>>$LOG_FILE
VALIDATE $? "install the dependencies"

cp /home/ec2-user/shell-script-practice/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "copy the backend services"

systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "deemon reload"

systemctl start backend  &>>$LOG_FILE
VALIDATE $? "start backend"

systemctl enable backend   &>>$LOG_FILE
VALIDATE $? "enable the backend"

dnf install mysql -y   &>>$LOG_FILE
VALIDATE $? "install the mysql"

mysql -h db.nsrikanth.online -uroot -p"${password}" < /app/schema/backend.sql  &>>$LOG_FILE
VALIDATE $? "load  the schema"

systemctl restart backend   &>>$LOG_FILE
VALIDATE $? "restart the backend"


