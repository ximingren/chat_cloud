#!/bin/bash
export PATH
HOSTNAME="172.17.0.2"
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="nextcloud"
TABLENAME="oc_activity"
select_id="SELECT activity_id FROM $TABLENAME"
activity_id=$(mysql -h$HOSTNAME  -u$USERNAME -p$PASSWORD $DBNAME -e  "$select_id")
latest_id=$(echo $activity_id | awk -F " " '{print $NF}')
last_id=$(cat ./latest_id)
if [ "$latest_id" -gt "$last_id" ];
then
   while [ "$latest_id" != "$last_id" ] 
   do
   let last_id+=1
   select_info="SELECT type,user,link FROM $TABLENAME WHERE activity_id=$last_id"
   cloud_info=$(mysql -h$HOSTNAME  -u$USERNAME -p$PASSWORD $DBNAME -N -e "$select_info")
   TYPE=$(echo $cloud_info | awk -F " " '{print $1}')
   USER=$(echo $cloud_info | awk -F " " '{print $2}')
   LINK=$(echo $cloud_info | awk -F " " '{print $3}')
   select_file="SELECT file from $TABLENAME WHERE activity_id=$latest_id"
   FILE=$(mysql -h$HOSTNAME -P$PORT -u$USERNAME -p$PASSWORD $DBNAME -N -e "$select_file")
#   TITLE=$LINK$FILE
#   TEXT=$USER$TYPE
   select_ChatName="SELECT chat_name FROM chat_cloud WHERE cloud_name='"$USER"'"
   CHAT_NAME=$(mysql -h$HOSTNAME  -u$USERNAME -p$PASSWORD $DBNAME -N -e"$select_ChatName") 
   curl -X POST -H 'Content-Type: application/json' --data "{\"text\":\"云盘信息\",\"attachments\":[{\"title\":\"$(echo $TYPE)\",\"title_link\":\"$(echo $LINK)\",\"text\":\"$(echo $CHAT_NAME'/'$TYPE$FILE)\",\"image_url\":\"https://rocket.chat/images/mockup.png\",\"color\":\"#764FA5\"}]}" http://localhost:3000/hooks/7XcXCkWDMGsBzxqZo/s6g64DH4Gtb2rg9t4tbiDkw72RW2XbNCxWs3C9xgcMzFyfpx
   done
fi
echo $latest_id > ./latest_id
