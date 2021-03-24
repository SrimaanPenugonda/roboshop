#!/bin/bash

COMPONENT=user
source components/common.sh

INFO "Setup user Component"
INFO " Install NodeJS"
yum install nodejs make gcc-c++ -y &>>$Log_File
STAT $? "NodeJS Installation"

INFO "Application user creation"
id roboshop &>>$Log_File
case $? in
  0)
    STAT 0 "Application User exits"
    ;;
  1)
    useradd roboshop &>>$Log_File
    STAT $? "Application User Created"
    ;;
esac

INFO "Download user Artifacts"
DOWNLOAD_ARTIFACTS "https://dev.azure.com/DevOps-Batches/f635c088-1047-40e8-8c29-2e3b05a38010/_apis/git/repositories/8cd1d535-7b52-4823-9003-7b52db898c08/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"

mkdir -p /home/roboshop/${COMPONENT}
cd /home/roboshop/${COMPONENT}
unzip -o /tmp/${COMPONENT} &>>$Log_File
STAT $? "Unzip Artifacts"
INFO "Install NodeJS dependencies"
npm install --unsafe-perm &>>$Log_File #unsafe param has to use when install as root user
STAT $? "NodeJS Dependencies Installation"

chown roboshop:roboshop /home/roboshop/${COMPONENT} -R #change group and user to roboshop
# now this path will change to roboshop user
INFO "Update systemd.service configuration"
sed -i -e "s/MONGO_ENDPOINT/mongo-test.devopssri.ml/" -e "s/REDIS_ENDPOINT/redis-test.devopssri.ml/" /home/roboshop/${COMPONENT}/systemd.service &>>$Log_File
STAT $? "MONGO_DNSNAME,REDIS_ENDPOINT updated"


INFO "Setup Systemd Service for user"
mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>$Log_File
INFO "Load the Service to system"
systemctl daemon-reload &>>$Log_File
STAT $? "user systemd loaded"

INFO  "Start user Service"
systemctl enable ${COMPONENT} &>>$Log_File
systemctl restart ${COMPONENT} &>>$Log_File
STAT $? "user Service Start"




