#!/bin/bash

#V.3

sleep 10

######### Install PPROXY ###################
sudo apt -y update
sudo apt -y install python3-pip
sudo apt -y install autossh
sudo pip3 install pproxy

sleep 5

##############Proxy START ###################

portNum=`cat /srv/weareproxy/portNumber.txt; echo`
unitFile="/etc/systemd/system/weareproxy.service"
mainFolder="/srv/weareproxy"
service="weareproxy.service"
url="<api-server>"  #server where to get port for proxying
sshUrl="<ssh_server>"
runFile="/srv/weareproxy/weareproxy-start.sh"
curl='/usr/bin/curl'
ipInfoUrl="https://ipinfo.io/ip"
IpAddress="$($curl $ipInfoUrl)"

#############################################

############################################

sudo chmod 400 $mainFolder/proxygate1   #change the rights on the ssh key

#############################################

sleep 5


if [[ $portNum -gt 0 ]]
then
  echo $portNum
  echo "Restarting  a weareproxy.service  ......."
  sudo systemctl restart  $service
  sleep 3
  echo "Weareproxy is Running on port "$portNum" .....! OK !"
  sleep 1
else
  echo "Getting  a new Port......!"
  portNum="0"
  while  [ "$portNum" = "0"  ];do
    portNum=`curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQW" -k -X POST $url:5023/api/getport  -d 'portN=getnew';echo`
    echo "Request port to $url"
    sleep 2
  done
  echo $portNum > /srv/weareproxy/portNumber.txt
  sleep 3
  echo "Port is: $portNum"
  echo "IP Address: $IpInfo"
  #####Send IP Info
#  sendIpInfo="`curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQW" -k -X POST $url:5023/api/ipinfo  -d 'port=$portNum&ip=IpAddress' " 
##############################################
  pproxyRun="/usr/local/bin/pproxy -l  http+socks4+socks5://127.0.0.1:$portNum &"
  autosshRun="/usr/bin/autossh -M 0 -N  -o 'StrictHostKeyChecking=no' -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 5' -i /srv/weareproxy/proxygate1 -R 127.0.0.1:$portNum:127.0.0.1:$portNum  testconnectuser2023@$sshUrl -p 443 &"

  echo "#! /bin/bash" > $runFile 
  echo $autosshRun >> $runFile
  echo $pproxyRun >> $runFile
  echo " " >> $runFile
  echo "curl='/usr/bin/curl'" >> $runFile
  echo "ipInfoUrl='https://ipinfo.io/ip' " >> $runFile
  echo "IpAddress='"$($curl $ipInfoUrl)"' " >> $runFile
  echo "portNum='"$portNum"' " >> $runFile
  echo " " >> $runFile
  echo "while true" >> $runFile
  echo "do"  >> $runFile
  echo "   echo  'Service is Run !!!' " >> $runFile
  echo "   sleep 600" >> $runFile
  echo "done" >> $runFile
  sudo chmod +x $runFile


  sleep 5

## Write a Unit file for running it as daemon##

  echo "[Unit]" > $unitFile
  echo "Description=RUNNING GATE on port " $portNum "!!!" >> $unitFile
  echo "Wants=network-online.target" >> $unitFile
  echo "After=network.target network-online.target multi-user.target" >> $unitFile
  echo " " >> $unitFile
  echo "[Service]" >> $unitFile
  echo "PIDFile=/tmp/weareproxy.pid" >> $unitFile
  echo "ExecStart=/srv/weareproxy/weareproxy-start.sh" >> $unitFile
  echo "Restart=always" >> $unitFile
  echo "RestartSec=120" >> $unitFile
  echo " " >> $unitFile
  echo "[Install]" >> $unitFile
  echo "WantedBy=multi-user.target" >> $unitFile

###########Systemctl ##################
  sleep 3

  sudo systemctl daemon-reload
  sudo systemctl enable $service
  sleep 2
  sudo systemctl start $service
  sudo systemctl restart $service
fi


#######################################


echo "Proxy is Running.....! OK ! "
echo " SSH Tunnel is Running ....! OK !"
