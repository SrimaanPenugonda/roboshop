#Common Script for RoboShop Project ,It can be used by all componets/services

Log_File=/tmp/roboshop.log #All Logs can check here
rm -f $Log_File #remove old logfile if exits

INFO(){
  echo -e "[\e[1;33mINFO\e[0m] [\e[1;34m${COMPONENT}\e[0m] [\e[1;35m$(date +%F:%T)\e[0m] $1"
}

SUCC(){
  echo -e "[\e[1;33mSUCCESS\e[0m] [\e[1;34m${COMPONENT}\e[0m] [\e[1;35m$(date +%F:%T)\e[0m] $1"
}

FAIL(){
  echo -e "[\e[1;33mFAIL\e[0m] [\e[1;34m${COMPONENT}\e[0m] [\e[1;35m$(date +%F:%T)\e[0m] $1"
  echo -e "[\n\e[1;31mRefer logs in : $Log_File for error\e[0m"
  exit 1
}

DOWNLOAD_ARTIFACTS() {
  curl -s -L -o /tmp/${COMPONENT}.zip $1 &>>$Log_File
  STAT $? "Artifact Download"
}

STAT(){   # To validate exit status of above operation
  case $1 in
  0)
    SUCC "$2"
    ;;
  *)
    FAIL "$2"
   ;;
   esac }
