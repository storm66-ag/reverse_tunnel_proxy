#!/usr/bin/python3

#v1.1

import subprocess
import sys
import time
import ssl
from ipaddress import ip_address
from urllib.request import urlopen
from json import load
import requests


filePort='<way_to_folder>/portNumber.txt'

###########Get a Hostname ###############################
def readfile(file):

  with open(file) as f:
      try:
          readInfo = f.readlines()
          portNum = readInfo[0].strip()
      except Exception as e:
#      print(e)
          portNum = "Oops...nothing!"
  return (portNum)

#########################################################

####################Get Country City ####################

def ipInfo():
    from urllib.request import urlopen
    from json import load
    url = 'https://ipinfo.io'
    res = urlopen(url)
    data = load(res)
    #will load the json response into data
    #print(data)
    ipAddressIs = data["ip"]
    country = data["country"] 
    city = data["city"]
    return ipAddressIs, country, city


def sendData(port,ip, country, city):
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
    port = readfile(filePort)
    url = 'https://proxy-api1.squidyproxy.com:5023/api/ipinfo'
    token = 'eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQW'
    headers = {"Authorization": f"Bearer {token}", 'cookie': '',}
    payload={'port': f'{port}', 'ip':f'{ip}', 'country':f'{country}','city':f'{city}'}
    try:
      response = requests.post(url, headers=headers, data=payload, verify=False)
      return (response.status_code)
    except Exception as e:
      return ("Oops...!")

port = readfile(filePort)
ipInformation = ipInfo()
ip = ipInformation[0]
country = ipInformation[1]
city = ipInformation[2]



try:
  sendData(port=f'{port}', ip=f'{ip}', country=f'{country}',city= f'{city}')
except Exception as e:
  print ("Failed...!")
