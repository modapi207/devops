# 7주차 - 도커 컴포즈

nginx + web 3개 + redis를 compose.yaml 하나로 띄우고, healthcheck와 .env로 운영에 가까운 구성 만들기

## 오늘 배운 내용

- compose.yaml: 여러 컨테이너의 구성을 파일 하나로 정의하고 `docker compose up` 한 번으로 실행
- 같은 compose 네트워크 안에서는 서비스 이름(`redis`, `web`)으로 서로 찾음
- `depends_on` + `condition: service_healthy`: redis가 응답 가능해진 뒤에 web을 시작
- volume: 컨테이너를 지워도 redis 데이터를 유지
- `--scale web=3`: web을 여러 개 띄우고 nginx가 요청을 나눠 줌 (리버스 프록시, 로드 밸런싱)
- 비밀번호는 compose.yaml이 아니라 `.env`에 두고 Git에는 `.env.example`만 올림

## 구성

```
브라우저 :8080 → nginx → web × 3 (:5000) → redis (:6379, volume redis-data)
```

파일: [`guestbook/compose.yaml`](../guestbook/compose.yaml), [`guestbook/nginx.conf`](../guestbook/nginx.conf), [`guestbook/.env.example`](../guestbook/.env.example)

## 1. docker compose ps (healthy 포함)

```
NAME                IMAGE            SERVICE   STATUS                    PORTS
guestbook-nginx-1   nginx:alpine     nginx     Up 10 seconds             0.0.0.0:8080->80/tcp
guestbook-redis-1   redis:7-alpine   redis     Up 22 seconds (healthy)   6379/tcp
guestbook-web-1     guestbook-web    web       Up 16 seconds (healthy)   5000/tcp
guestbook-web-2     guestbook-web    web       Up 17 seconds (healthy)   5000/tcp
guestbook-web-3     guestbook-web    web       Up 16 seconds (healthy)   5000/tcp
```

- redis와 web 3개 모두 healthcheck를 통과해 `healthy`
- nginx는 web이 healthy가 된 뒤에 시작됨 (redis 22초 → web 16~17초 → nginx 10초)

## 2. scale 후 호스트명이 바뀌는 화면

`docker compose up -d --scale web=3` 후 새로고침할 때마다 화면의 Host 이름이 바뀜. nginx가 요청을 web 3개에 돌아가며 보내기 때문. 글은 어느 web으로 가도 똑같이 보임. 데이터는 redis 하나에 있기 때문

## 3. down 후 up vs down -v 후 up

| 명령 | 컨테이너 | volume(redis-data) | 방명록 글 |
|---|---|---|---|
| `docker compose down` → `up -d` | 삭제 후 다시 생성 | 유지 | 남아 있음 |
| `docker compose down -v` → `up -d` | 삭제 후 다시 생성 | 삭제 | 사라짐 |

- `-v`는 volume까지 지우는 옵션. 데이터가 날아가므로 함부로 쓰지 않기

## 4. .env를 Git에 올리지 않는 이유

- 이 레포는 공개라서 `.env`를 올리면 redis 비밀번호를 누구나 볼 수 있음
- 한 번 커밋하면 나중에 파일을 지워도 커밋 기록에 남음
- 그래서 `.env`는 `.gitignore`로 막고, 어떤 변수가 필요한지만 `.env.example`로 공유

## 호기심 (48p) - web=3을 항상 유지하려면?

`restart: unless-stopped`는 컨테이너가 스스로 죽었을 때만 다시 띄우고, `docker stop`으로 멈춘 건 살리지 않음. 도커는 "web 3개"라는 목표 개수도 기억하지 않음

그래서 사람이 하던 "개수 확인 → 모자라면 3개로"를 셸 스크립트에 맡기는 방법을 생각해 봄

```bash
#!/bin/bash
cd "$(dirname "$0")" || exit 1
DESIRED=3
while true; do
  RUNNING=$(docker compose ps --status running -q web | wc -l)
  if [ "$RUNNING" -lt "$DESIRED" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') web ${RUNNING}개 → ${DESIRED}개로 복구" >> keep_web3.log
    docker compose up -d --scale web="$DESIRED" --no-recreate
  fi
  sleep 10
done
```

- 장점: 지금까지 배운 셸 스크립트와 compose 명령만으로 가능, 사람이 멈춘 경우도 복구, 로그가 남음
- 단점: 확인 간격(10초) 동안은 2개로 운영, 일부러 줄이고 싶을 때도 다시 늘림, 계속 죽는 이미지도 계속 다시 띄움
- 한계: 스크립트가 꺼지면 끝, compose는 컴퓨터 한 대 안에서만 동작해서 서버가 꺼지면 전부 멈춤, redis는 여전히 1개
- 결국 "원하는 상태와 현재 상태를 계속 비교해서 맞추는 일"을 손으로 흉내 낸 것. 다음 시간 쿠버네티스에서 이어짐

## 실습 캡처
![스크린샷 2026-10-23 223345.png](<images/스크린샷 2026-10-23 223345.png>)
![스크린샷 2026-10-23 223355.png](<images/스크린샷 2026-10-23 223355.png>)
![스크린샷 2026-10-23 223534.png](<images/스크린샷 2026-10-23 223534.png>)
![스크린샷 2026-10-23 223619.png](<images/스크린샷 2026-10-23 223619.png>)
![스크린샷 2026-10-23 223735.png](<images/스크린샷 2026-10-23 223735.png>)
