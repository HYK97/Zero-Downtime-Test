BASE_PATH=/home/app/
JAR_NAME=demo-0.0.1-SNAPSHOT.jar
echo "> build 파일명: $JAR_NAME"

# 흐름 서버 1 업데이트 시작 하고 -> nginx 막기(근데 롤링방식이라 서버끊기면 자동으로 바뀜) -> 자연스럽게 두번째
echo "> 현재 구동중인 Set 확인"
#비공개 ip
IP1=# ip
IP2=# ip
MY_IP=$(hostname -i)
OTHER_IP
loop=1
limitLoop=30
flag='false'


if [ $MY_IP == $IP1 ]; then
  OTHER_IP=$IP2
elif [ $MY_IP == $IP2 ]; then
  OTHER_IP=$IP1
else
  echo "> 일치하는 IP가 없습니다. "
fi

echo 내 "> ip" $MY_IP
echo 내 "> OTHER_IP" $OTHER_IP


#===================================살아있는 서버확인======================================
echo "> 서버 체크 시작"
for retry_count in {1..10};
do
  response=$(sudo curl -s http://$OTHER_IP:8080/actuator/health)
  up_count=$(echo $response | grep 'UP' | wc -l)
  echo "> $retry_count : $response  : $up_count"
  echo "> 현재서버IP : $MY_IP 타서버 IP : $OTHER_IP"
  if [ $up_count -ge 1 ]; then
    echo "> 서버 체크 성공"
    break
  fi
  if [ $retry_count -eq 10 ]; then
    echo "> 실패"
    exit 1
  fi
  echo "> 실패 50초후 재시도"
  sleep 5
  #다른 서버 업데이트
done

#===================================프로세스 종료======================================
# tomcat gracefully shutdown
echo "> 구동중인 애플리케이션 pid 확인"
IDLE_PID=(`ps -ef | grep  $JAR_NAME | grep -v 'grep' | awk '{ print $2 }'`)
 if [ ${#IDLE_PID[@]} = 0 ]
then
  echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
  flag='true'
else
  for pid in "${IDLE_PID[@]}"
  do
      echo "> [$pid] gracefully shutdown"
      kill -15 $pid
  done
  while [ $loop -le $limitLoop ]
  do
      PID_LIST=(`ps -ef | grep  $JAR_NAME | grep -v 'grep' | awk '{ print $2 }'`)
      if [ ${#PID_LIST[@]} = 0 ]
      then
          echo "> gracefully shutdown success "
          flag='true'
          break
      else
          for pid in "${PID_LIST[@]}"
          do
              echo "> [$loop/$limitLoop] $pid 프로세스 종료를 기다리는중입니다."
          done
          loop=$(( $loop + 1 ))
          sleep 1
          continue
      fi
  done
fi
if [ $flag == 'false' ];
then
    echo "> 프로세스 강제종료 시도"
    sudo ps -ef | grep $JAR_NAME | grep -v 'grep' |  awk '{ print $2 }' | \
    while read PID
    do
        echo "> [$PID] forced shutdown"
        kill -9 $PID
    done
fi


#===================================배포======================================
echo "> 배포"
echo "> 파일명" $BASE_PATH$JAR_NAME
sudo nohup java -jar -Dspring.profiles.active=set1 $BASE_PATH$JAR_NAME &
sudo sleep 10

echo "> 10초 후 Health check 시작"
echo "> curl -s http://$MY_IP:8080/actuator/health"


#===================================서버 Health check  ======================================
for retry_count in {1..10}; do
  response=$(sudo curl -s http://$MY_IP:8080/actuator/health)
  up_count=$(echo $response | grep 'UP' | wc -l)
  if [ $up_count -ge 1 ]; then
    echo "> Health check 성공"
    break
  else
    echo "> Health check의 응답을 알 수 없거나 혹은 status가 UP이 아닙니다."
    echo "> Health check: ${response}"
  fi

  if [ $retry_count -eq 10 ]; then
    echo "> Health check 실패. "
    echo "> Nginx에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..."
  sudo sleep 10
done

sleep 60 # 다음 배포서버 지연

#JENKINS_NODE_COOKIE=dontKillMe