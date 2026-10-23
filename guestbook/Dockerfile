# 파이썬 3.12가 설치된 가벼운(slim) 이미지에서 시작
FROM python:3.12-slim
# 이후 명령을 실행할 컨테이너 안 작업 폴더
WORKDIR /app

# 의존성 목록만 먼저 복사하고 설치 (코드가 바뀌어도 이 층은 캐시로 재사용)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# 나머지 코드 복사 (.dockerignore에 적힌 파일은 제외)
COPY . .
# root가 아닌 일반 사용자로 실행 (보안)
RUN useradd -m appuser
USER appuser
# 앱 설정값을 이미지에 구워 넣음 (docker run -e로 덮어쓸 수 있음)
ENV APP_TITLE="수아의 DevOps 방명록" \
    THEME_COLOR="#0000FF"
# 이 컨테이너가 5000번 포트를 쓴다는 표시 (실제 공개는 -p)
EXPOSE 5000
# 컨테이너가 켜질 때 실행할 명령
CMD ["python", "app.py"]
