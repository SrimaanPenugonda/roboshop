#!/bin/bash

COMPONENT=mongodb

source components/common.sh

INFO "Setup mongodb Service"
INFO "Setup Mongodb Repository"
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
STAT $? "Mongodb Repository setup"

INFO "Install Mongodb"
yum install mongodb-org -y &>>$Log_File
STAT $? "Mongodb Installation"

INFO "Update mongodb configuration \e[34mmongod.conf\e[0m file with 0.0.0.0"
if [ -f /etc/mongod.conf ]; then
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$Log_File
STAT $? "mongodb configuration update"
else
STAT 1 "mongod.conf file missing"
fi

INFO "Restart MongoDB"
systemctl enable mongod &>>$Log_File
systemctl restart mongod &>>$Log_File
STAT $? "Mongodb Started"

INFO "Download MongoDB Artifacts"
DOWNLOAD_ARTIFACTS "https://dev.azure.com/DevOps-Batches/f635c088-1047-40e8-8c29-2e3b05a38010/_apis/git/repositories/03f2af34-e227-44b8-a9f2-c26720b34942/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
STAT $? "Artifacts Download"
cd /tmp
unzip -o ${COMPONENT}.zip &>>$Log_File
STAT $? "Unzip Artifacts"
INFO "Load Schema for catalogue and users"
mongo < catalogue.js &>>$Log_File
STAT $? "Catalogue schema loaded"
mongo < users.js &>>$Log_File
STAT $? "Users schema loaded"


