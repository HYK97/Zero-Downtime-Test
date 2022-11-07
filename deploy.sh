#!/bin/bash
BASE_PATH=/home/app/
JAR_NAME=demo-0.0.1-SNAPSHOT.jar
echo "> build 파일명: $JAR_NAME"

echo "> 현재 구동중인 Set 확인"
CURRENT_PROFILE=$(curl -s http://localhost/profile)
echo "> $CURRENT_PROFILE"

# 흐름 서버 1 업데이트 시작 하고 -> nginx 막기(근데 롤링방식이라 서버끊기면 자동으로 바뀜) -> 자연스럽게 두번째

echo ">  구동중인 애플리케이션 pid 확인"
IDLE_PID=$(pgrep -f JAR_NAME)

if [ -z $IDLE_PID ]
then
  echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
  echo "> kill -15 $IDLE_PID"
  kill -15 $IDLE_PID
  sleep 5
fi

echo "> 배포"
nohup java -jar $BASE_PATH$JAR_NAME &

echo "> 10초 후 Health check 시작"
echo "> curl -s http://localhost:8080/actuator/health"
sleep 10

for retry_count in {1..10}
do
  response=$(curl -s http://localhost:8080/actuator/health)
  up_count=$(echo $response | grep 'UP' | wc -l)

  if [ $up_count -ge 1 ]
  then # $up_count >= 1 ("UP" 문자열이 있는지 검증)
      echo "> Health check 성공"
      break
  else
      echo "> Health check의 응답을 알 수 없거나 혹은 status가 UP이 아닙니다."
      echo "> Health check: ${response}"
  fi

  if [ $retry_count -eq 10 ]
  then
    echo "> Health check 실패. "
    echo "> Nginx에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..."
  sleep 10
done