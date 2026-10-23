# 6주차 - Dockerfile과 이미지 배포

내 코드로 Dockerfile을 작성해 이미지를 만들고, ghcr.io에 올려 다른 PC에서 받아 실행

## 오늘 배운 내용

- Dockerfile은 이미지를 만드는 레시피. FROM → WORKDIR → COPY → RUN → ENV → EXPOSE → CMD
- RUN은 이미지를 만들 때, CMD는 컨테이너를 켤 때 실행
- 레이어 캐시: 바뀌지 않은 줄은 다시 실행하지 않고 재사용. 자주 바뀌는 코드(`COPY . .`)는 뒤에 둠
- 배포 흐름: build → tag → push → (친구) pull → run
- 이미지는 프로그램을 공유할 뿐 데이터는 공유하지 않음. 글은 각자 컨테이너 메모리에 저장

## 내 이미지

- `ghcr.io/modapi207/guestbook:v1`
- `ghcr.io/modapi207/guestbook:v2` (ENV 제목·색상, 화면 문구 수정)
- 패키지 목록: https://github.com/modapi207?tab=packages

## Dockerfile 각 줄이 하는 일

```dockerfile
FROM python:3.12-slim          # 파이썬 3.12가 들어 있는 가벼운 이미지에서 시작
WORKDIR /app                   # 이후 명령을 실행할 컨테이너 안 작업 폴더
COPY requirements.txt .        # 의존성 목록만 먼저 복사
RUN pip install --no-cache-dir -r requirements.txt   # 라이브러리 설치. 코드가 바뀌어도 이 층은 캐시로 재사용
COPY . .                       # 나머지 코드 복사 (.dockerignore에 적힌 건 제외)
RUN useradd -m appuser         # root가 아닌 일반 사용자 생성
USER appuser                   # 이후 실행은 일반 사용자 권한으로 (보안)
ENV APP_TITLE="..." THEME_COLOR="..."   # 앱 설정값을 이미지에 구워 넣음
EXPOSE 5000                    # 이 컨테이너가 5000번 포트를 쓴다는 표시 (실제 공개는 -p)
CMD ["python", "app.py"]       # 컨테이너가 켜질 때 실행할 명령
```

## 빌드 캐시 (CACHED)

v2를 빌드할 때 `requirements.txt`는 그대로라서 `pip install` 층까지 `CACHED`로 재사용되고, 코드를 복사하는 `COPY . .`부터 다시 실행됨. 그래서 의존성 설치(`COPY requirements.txt` → `RUN pip install`)를 코드 복사보다 앞에 둠

## 친구 이미지 위에 내 설정 굽기 (Dockerfile.custom)

```dockerfile
FROM ghcr.io/makyraen/inhatc-devops-guestbook:v1
ENV APP_TITLE="방명록" \
    THEME_COLOR="#7C9A82"
```

- 친구 이미지도 `python:3.12-slim`처럼 FROM에 쓸 수 있음. 친구 이미지의 레이어 위에 ENV 층만 추가됨 (`docker history`로 확인)
- 내 PC에 친구 소스 코드도, Flask도 없는데 실행됨

## 설정을 넣는 세 가지 방법

| 방법 | 위치 | 우선순위 |
|---|---|---|
| 코드 기본값 | `app.py`의 `os.environ.get("THEME_COLOR", "#DC143C")` | 가장 낮음 |
| ENV | Dockerfile에 구워 넣음 | 중간 |
| `docker run -e` | 실행할 때 주입 | 가장 높음 |

- `guestbook:custom`(ENV `#7C9A82`)에 `-e THEME_COLOR="#16a34a"`를 주고 실행하면 `#16a34a`가 적용됨

## 실습 캡처
![스크린샷 2026-10-23 165551.png](<images/스크린샷 2026-10-23 165551.png>)
![스크린샷 2026-10-23 211541.png](<images/스크린샷 2026-10-23 211541.png>)
![스크린샷 2026-10-23 221350.png](<images/스크린샷 2026-10-23 221350.png>)
![스크린샷 2026-10-23 221705.png](<images/스크린샷 2026-10-23 221705.png>)
![스크린샷 2026-10-23 221855.png](<images/스크린샷 2026-10-23 221855.png>)
![스크린샷 2026-10-23 221938.png](<images/스크린샷 2026-10-23 221938.png>)
