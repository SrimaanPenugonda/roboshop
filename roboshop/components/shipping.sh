#!/bin/bash/

COMPONENT=shipping
source components/common.sh

INFO "Setup Shipping Component"
INFO "Installing Maven"

yum install maven -y &>>$Log_File
STAT $? "Maven Installation"

INFO "Create Application user"

id roboshop &>>$Log_File
case $? in
  0)
    STAT 0 "Application User Exits"
    ;;
  1)
    useradd roboshop &>>$Log_File
    STAT $? "roboshop user created"
    ;;
esac
INFO "Downloading Artifacts"
DOWNLOAD_ARTIFACTS "https://dev.azure.com/DevOps-Batches/f635c088-1047-40e8-8c29-2e3b05a38010/_apis/git/repositories/9c06b317-6353-43f6-81e2-aa4f5f258b2d/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
STAT $? "Artifacts Downloaded"
mkdir -p /home/roboshop/${COMPONENT}
cd  /home/roboshop/${COMPONENT}
unzip -o /tmp/${COMPONENT}.zip &>>$Log_File
STAT $? "Artifacts Unzip Completed"

INFO "Compile Shipping Application"
mvn clean package  &>>$Log_File
mv target/shipping-1.0.jar shipping.jar  &>>$Log_File
STAT $? "Shipping Compile"

chown roboshop:roboshop /home/roboshop/${COMPONENT} -R
INFO "Configuring Shipping Startup Script "
sed -i -e "s/CARTENDPOINT/cart-test.devopssri.ml/" -e "s/DBHOST/mysql-test.devopssri.ml/" /home/roboshop/${COMPONENT}/systemd.service
STAT $? "CARTENDPOINT,DBHOST endpoint updated"

INFO "Setup systemd service for shipping"
mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
systemctl daemon-reload
STAT $? "shipping serviced loaded"

INFO "Start shipping service"
systemctl enable ${COMPONENT} &>>$Log_File
systemctl restart ${COMPONENT} &>>$Log_File
STAT $? "shipping service started"






