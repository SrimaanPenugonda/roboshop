#!/bin/bash

COMPONENT=frontend
source components/common.sh

INFO "Setup Frontend Service"
INFO "Installing Nginx"
yum install nginx -y &>>$Log_File
STAT $? 'Nginx Installation'

INFO "Download frontend Artifact"
DOWNLOAD_ARTIFACTS "https://dev.azure.com/DevOps-Batches/f635c088-1047-40e8-8c29-2e3b05a38010/_apis/git/repositories/fdf87296-ccbe-45e5-a615-bc6ecbd78bfe/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"

INFO "Remove Old Artifacts"
cd /usr/share/nginx/html
rm -rvf * &>>$Log_File
STAT $? "Artifacts Removal"

INFO "Unzip Artifacts"
unzip -o /tmp/${COMPONENT}.zip &>>$Log_File
mv static/* .
STAT $? "Artifacts Extract"

INFO "Update Nginx Configuration"
cp localhost.conf /etc/nginx/default.d/roboshop.conf
##sed -i -e "/catalogue/ s/catalogue:/localhost:/" /etc/nginx/default.d/roboshop.conf
sed -i  -e "/catalogue/ s/catalogue:/catalogue-dev.devopssri.ml:/" \
        -e "/cart/ s/localhost/cart-dev.devopssri.ml/" \
        -e "/user/ s/localhost/user-dev.devopssri.ml/" \
        -e "/shipping/ s/localhost/shipping-dev.devopssri.ml/" \
        -e "/payment/ s/localhost/payment-dev.devopssri.ml/" \
        /etc/nginx/default.d/roboshop.conf
STAT $? "Nginx configuration update"

INFO "Nginx Restart"
systemctl enable nginx &>>$Log_File
systemctl restart nginx &>>$Log_File
STAT $? "Nginx Service Startup"


