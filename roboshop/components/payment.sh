#!/bin/bash

COMPONENT=payment
source components/common.sh

INFO "Start Payment Setup"
INFO "Installing Python3"
yum install python36 gcc python3-devel -y &>>$Log_File
STAT $? "Python 3 Install"

INFO "Create Application User"
id roboshop &>>$Log_File
case $? in
  0)
    STAT 0 "Application User Creation"
    ;;
  1)
    useradd roboshop &>>$Log_File
  STAT $? "Application User Created"
  ;;
esac


INFO "Download Payment Artifact"
DOWNLOAD_ARTIFACTS "https://dev.azure.com/DevOps-Batches/f635c088-1047-40e8-8c29-2e3b05a38010/_apis/git/repositories/cd32a975-ee45-4b3b-a08e-8e97c3ca7733/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"


INFO "unzip Downloaded Artifacts"
mkdir -p /home/roboshop/${COMPONENT}
cd /home/roboshop/${COMPONENT}
unzip -o /tmp/payment.zip &>>$Log_File
STAT $? "Artifacts unzip"

chown roboshop:roboshop  /home/roboshop/${COMPONENT} -R &>>$Log_File

INFO "Install Python Dependencies"
pip3 install -r requirements.txt &>>$Log_File
STAT $? "Dependencies Download"

INFO "Update userid and groupid in payment.ini file"
USER_UID=$(id -u roboshop)
USER_GID=$(id -g roboshop)
sed -i -e "/uid =/ c/uid ={USER_UID}" \
       -e "/gid =/ c/gid ={USER_GID}" \
    /home/roboshop/${COMPONENT}/payment.ini
STAT $? "userid,groupid updated"

INFO "Update systemd.service file"
sed -i  -e "s/CARTHOST/cart-test.devopssri.ml/" \
        -e "s/USERHOST/user-test.devopssri.ml/" \
        -e "s/AMQPHOST/rabbitmq-test.devopssri.ml/" \
        /home/roboshop/${COMPONENT}/systemd.service
STAT $? "cart,user,rabbitmq endpoints updated"
INFO "setup payment service file"
mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
systemctl daemon-reload
STAT $? "Payment SystemD Service"

INFO "Starting Payment Service"
systemctl enable ${COMPONENT} &>>$Log_File
systemctl restart ${COMPONENT} &>>$Log_File
STAT $? "Payment Service Start"
