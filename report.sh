#!/bin/bash

username="$LNUT_USER"     # 888888888
password="$LNUT_PASSWORD" # 123456
nowaddress="$NOW_ADDRESS" # 辽宁省-锦州市
spliter=(${nowaddress//-/ })

convince="${spliter[0]}"
city="${spliter[1]}"

reportdate=$(TZ=CST-8 date +"%Y-%-m-%d")

if [[ -z $username ]]; then
  echo "miss LNUT_USER"
  exit 1
fi

if [[ -z $password ]]; then
  echo "miss LNUT_PASSWORD"
  exit 1
fi

if [[ -z $nowaddress ]]; then
  echo "miss NOW_ADDRESS"
  exit 1
fi

if [[ -z $convince ]]; then
  echo "could not get convince from NOW_ADDRESS"
  exit 1
fi

if [[ -z $city ]]; then
  echo "could not get city from NOW_ADDRESS"
  exit 1
fi

user=$(
  curl 'http://fy.lnut.edu.cn/iframe/sys/fylogin' \
    -H 'Connection: keep-alive' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36' \
    -H 'Content-Type: application/json' \
    -H 'Accept: */*' \
    -H 'Origin: http://fy.lnut.edu.cn' \
    -H 'Referer: http://fy.lnut.edu.cn/pages/login/index' \
    -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' \
    --data-binary '{"username":"'"$username"'","password":"'"$password"'"}' \
    --compressed \
    --insecure \
    -s
)

token=$(echo "$user" | jq -r '.result.token')

if [[ -z $token || $token == null ]]; then
  echo 'login failed'
  exit 1
fi

report=$(
  curl 'http://fy.lnut.edu.cn/iframe/report/report/add' \
    -H 'Connection: keep-alive' \
    -H 'X-Access-Token: '"${token}"'' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36' \
    -H 'Content-Type: application/json' \
    -H 'Accept: */*' \
    -H 'Origin: http://fy.lnut.edu.cn' \
    -H 'Referer: http://fy.lnut.edu.cn/pages/report/index' \
    -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' \
    --data-binary '{"nowaddress":"'"$nowaddress"'","trival":"","convince":"'"$convince"'","city":"'"$city"'","sfqz":"否","sfys":"否","sfgl":"否","jcqzry":"否","jcysry":"否","jcglry":"否","sffrks":"否","sfgjbs":"否","sno":"'"$username"'","s1":"否","reportdate":"'"$reportdate"'"}' \
    --compressed \
    --insecure \
    -s
)

echo "$report"

message=$(echo "$report" | jq '.message')

if [[ $message != *"添加成功"* ]]; then
  exit 1
fi
