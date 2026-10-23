#!/bin/bash
# web 컨테이너를 3개로 유지하는 스크립트
# 실행: ./keep_web3.sh (종료: Ctrl+C)
cd "$(dirname "$0")" || exit 1

DESIRED=3
INTERVAL=10
LOG="keep_web3.log"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker를 먼저 설치하세요." >&2
  exit 1
fi

while true; do
  # 실행 중인 web 개수 확인
  RUNNING=$(docker compose ps --status running -q web | wc -l)

  # 3개보다 적으면 다시 맞추기
  if [ "$RUNNING" -lt "$DESIRED" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') web ${RUNNING}개 -> ${DESIRED}개로 복구" >> "$LOG"
    docker compose up -d --scale web="$DESIRED" --no-recreate
  fi

  # unhealthy 상태인 web 재시작
  for ID in $(docker ps -q \
      --filter "label=com.docker.compose.service=web" \
      --filter "health=unhealthy"); do
    echo "$(date '+%Y-%m-%d %H:%M:%S') unhealthy web 재시작: $ID" >> "$LOG"
    docker restart "$ID"
  done

  sleep "$INTERVAL"
done
