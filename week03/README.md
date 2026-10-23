# 3주차 - 셸 스크립팅

Ollama + Qwen으로 로컬 AI 채팅 서비스 실행, 실행 절차를 셸 스크립트로 묶어 자동화

## 오늘 배운 내용

- 반복 작업은 사람이 하면 실수가 생김. 스크립트로 만들면 매번 같은 절차로 실행
- 흐름: 브라우저(`localhost:8000`) → `chat.py` → Ollama(`127.0.0.1:11434`) → Qwen 모델
- shebang(`#!`): 첫 줄에서 해석할 프로그램 지정. `./파일`로 실행할 때만 적용
- `cd "$(dirname "$0")" || exit 1`: 어디서 실행하든 스크립트 위치로 이동, 실패 시 종료
- `export`: 스크립트에서 정한 값을 실행할 프로그램에 전달 (`MODEL`, `WEB_PORT`)
- `if ! command -v python3 >/dev/null 2>&1`: 필요한 프로그램이 없으면 안내 후 `exit 1`로 실패 종료

## 새로 배운 명령어

```bash
curl -fsSL https://ollama.com/install.sh | sh   # Ollama 설치
ollama --version
curl -fsS http://127.0.0.1:11434/api/tags       # Ollama 서버 응답 확인
ollama pull qwen3:0.6b                          # 모델 다운로드
ollama list
mkdir -p week03/qwen-web                        # -p: 상위 폴더까지 같이 생성
cp "/mnt/c/Users/.../chat.py" .                 # 윈도우 다운로드 폴더에서 복사
python3 chat.py
!python3                                        # python3로 시작한 최근 명령 재실행
chmod u+x start.sh
./start.sh
echo $PATH
command -v python3
echo $?                                         # 직전 명령의 종료 코드
```

```bash
cat > start_with_export.sh << 'EOF'   # EOF가 나올 때까지 입력을 파일로 저장 (heredoc)
...
EOF
```

- `'EOF'`처럼 따옴표를 쓰면 `$MODEL` 같은 변수가 글자 그대로 저장됨. 따옴표가 없으면 지금 값으로 바뀌어 저장됨

## 실습 기록

`week03/qwen-web/`

- `chat.py`: LMS에서 받은 파이썬 웹 앱. 다른 모델 실습으로 기본 모델을 `qwen3:1.7b`로 변경
- `start.sh`: `chat.py` 실행 스크립트 + python3 설치 확인 조건문
- `run_py.sh`: shebang을 파이썬으로 지정해 본 파일
- `start_with_export.sh`: `MODEL` 환경 변수를 지정하고 `start.sh` 실행
- `start_with_export_2.sh`: `WEB_PORT=8080`으로 포트를 바꿔 실행 (`localhost:8080`)

3주차 파일은 수업 당일에 커밋하지 않아서, 5주차 커밋(`56b65c3 week05 Docker`)에 같이 올라감

## 트러블슈팅

- `start_with_export_2.sh` 실행 권한 누락
  - Git에 `100644`로 기록돼 있었음 → `chmod u+x` 후 `100755`
- `bash -n`으로 문법 검사를 하다가 `run_py.sh`에서 syntax error
  - `bash -n`은 shebang을 무시하고 Bash 문법으로 검사하기 때문. 파이썬 파일은 `./run_py.sh`로 실행해서 확인
