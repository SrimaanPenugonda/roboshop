#!/bin/bash

COMPONENT=rabbitmq
source components/common.sh

INFO "Setup RabbitMQ Component"

INFO "Install ErLang"
yum list esl-erlang &>>$Log_File
case $? in
  0)
    STAT 0 "ErLang already installed"
    ;;
  1)
    yum install https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2.1-1~centos~7_amd64.rpm -y &>>$Log_File
    STAT $? "ErLang Installation"
    ;;
esac

INFO "Setup RabbitMQ Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$Log_File
STAT $? "RabbitMQ Yum repos setup"

INFO "Install RabbitMQ Server"
yum install rabbitmq-server -y &>>$Log_File
STAT $? "RabbitMQ server Install"

INFO "Start RabbitMQ Service"
systemctl enable rabbitmq-server  &>>$Log_File
systemctl restart rabbitmq-server &>>$Log_File
STAT $? "Start RabbitMQ Service"

INFO "Create RoboShop App User in RabbitMQ"
rabbitmqctl add_user roboshop roboshop123 &>>$Log_File
rabbitmqctl set_user_tags roboshop administrator &>>$Log_File
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$Log_File #read,write,execute permissions
STAT $? "RoboShop App User create"
