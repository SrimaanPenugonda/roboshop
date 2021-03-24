#!/bin/bash/

COMPONENT=redis

source components/common.sh

INFO "Setup Redis Component"

INFO "Setup REDIS Yum repos"
yum install epel-release yum-utils -y &>>$Log_File
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$Log_File
yum-config-manager --enable remi &>>$Log_File
STAT $? "Yum repos configured"

INFO "Install Redis"
yum install redis -y &>>$Log_File
STAT $? "Redis Installation"

INFO "Update Redis Configuration redis.conf"
if [ -f /etc/redis.conf ]; then
  sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis.conf &>>$Log_File
  STAT $? "redis conf file update"
  sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis/redis.conf &>>$Log_File
  echo "Another redis conf /etc/redis/redis.conf file update"
else
  STAT 1 "redis.conf file missing"
fi

INFO "Start Redis"
systemctl enable redis &>>$Log_File
systemctl restart redis &>>$Log_File
STAT $? "Redis Service Startup"
