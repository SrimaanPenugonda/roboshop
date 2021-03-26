#!/bin/bash/

COMPONENT=mysql

source components/common.sh

INFO "Setup Mysql Db"
INFO "Setup Mysql Yum repos"
echo '[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
STAT $? "Mysql yum repository"

INFO " Install Mysql"

yum remove mariadb-libs -y &>>$Log_File
yum install mysql-community-server -y &>>$Log_File
STAT $? "Mysql Installation"

INFO "Start MYSQL Service"
systemctl enable mysqld &>>$Log_File
systemctl start mysqld &>>$Log_File
STAT $? "MYSQL Service Startup"

INFO "Change the password"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'P@5sw0rd123';
uninstall plugin validate_password;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';" >/tmp/schema.sql

MYSQL_DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}') #NF means get the last column of record

INFO "Reset MySQL Password"
echo show databases | mysql -u root -ppassword &>>$Log_File
case $? in
  0)
    STAT 0 "Password Reset"
    ;;
  1)
    mysql --connect-expired-password -u root -p${MYSQL_DEFAULT_PASSWORD} < /tmp/schema.sql &>>$Log_File
    STAT $? "Password Reset"
    ;;
esac
  INFO "Download MySQL Schema"
  DOWNLOAD_ARTIFACTS "https://dev.azure.com/DevOps-Batches/f635c088-1047-40e8-8c29-2e3b05a38010/_apis/git/repositories/2235ab8a-3229-47d9-8065-b56713ed7b28/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
  STAT $? "Artifacts Download"

INFO "Load the Schema"

cd /tmp/
unzip -o /tmp/${COMPONENT}.zip &>>$Log_File
mysql -u root -ppassword <shipping.sql &>>$Log_File

STAT $? "Schema Load"








