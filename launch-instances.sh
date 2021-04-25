#!/bin/bash

echo "Managing roboshop project servers"

case $1 in
      launch)
        echo "launching 10 instances"
        for component in frontend catalogue cart user shipping payment mysql mongo rabbitmq redis;do
         echo "Launch ${component} spot instance"
         aws ec2 run-instances --launch-template LaunchTemplateId=lt-0abcc8f4257b802e3 --tag-specifications \
         "ResourceType=instance,Tags=[{Key=Name,Value=${component}}]" &>>/tmp/instanceslaunch_log
        done
      ;;
      routes)
        echo "updating routes"
        for component in frontend catalogue cart user shipping payment mysql mongo rabbitmq redis;do
          echo "create A record for ${component}"
          IP=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${component} Name=instance-state-name,Values=running | jq \
          '.Reservations[].Instances[].PrivateIpAddress')
          sed -e "s/COMPONENT/${component}/" -e "s/IPADDRESS/${IP}/" record.json >/tmp/${component}.json
          aws route53 change-resource-record-sets --hosted-zone-id Z02790743IF4OLO4KMMFA --change-batch file:///tmp/${component}.json
          done
        ;;
      terminate)
        echo "terminating instances"
        for component in frontend catalogue cart user shipping payment mysql mongo rabbitmq redis;do
          echo "terminating ${component} instance"
          aws ec2 terminate-instances --instance-ids  $(aws ec2 describe-instances --filters \
          Name=tag:Name,Values=${component} \
          --query 'Reservations[].Instances[].InstanceId' --output text) &>>/tmp/instanceslaunch_log
         done
        ;;
esac

