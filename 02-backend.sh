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

dnf module disable nodejs -y
VALIDATE $? "disable the nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enable nodejs"

dnf install nodejs -y
VALIDATE $? "install the node js"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "create the user"
else
    echo -e "$Y alredy user created $N"
fi

mkdir -p /app
VALIDATE $? "creating  the app directory"

rm -rf /app
VALIDATE $? "remove everything in app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "download the backend code"

cd /app
VALIDATE $? "move  to app"

unzip /tmp/backend.zip
VALIDATE $? "unzip the code"

cd /app
VALIDATE $? "move to app"

npm install
VALIDATE $? "install the dependencies"

cp /home/ec2-user/shell-script-practice/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copy the backend services"

systemctl daemon-reload
VALIDATE $? "deemon reload"

systemctl start backend
VALIDATE $? "start backend"

systemctl enable backend
VALIDATE $? "enable the backend"

dnf install mysql -y
VALIDATE $? "install the mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -p"${password}" < /app/schema/backend.sql
VALIDATE $? "load  the schema"

systemctl restart backend
VALIDATE $? "restart the backend"


