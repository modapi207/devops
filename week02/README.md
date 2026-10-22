# 2주차 - 실습 환경 구축과 버전 관리 기초

WSL2 + Ubuntu로 리눅스 실습 환경 구성, Git/GitHub로 첫 저장소 생성 및 푸시

## 오늘 배운 내용

### 서버와 가상화

- 서버는 문맥에 따라 하드웨어(전원을 끄는 대상)도, 소프트웨어(설치하는 대상)도 됨
- 베어메탈: 물리 서버에 OS 하나를 올려 직접 사용
- 하이퍼바이저: 서버 한 대에 가상 머신 여러 개. 가상 머신마다 게스트 OS와 커널이 따로 있어 무거움
- 컨테이너: 모든 컨테이너가 호스트 OS 커널을 공유. 게스트 OS가 없어 가볍고 빠름
- 가상 머신의 요청 경로: 프로그램 → 게스트 OS 커널 → 가상 하드웨어 → 하이퍼바이저 → 실제 하드웨어. 컨테이너는 이 중간 단계가 빠짐

### WSL2

- BIOS 가상화 확인 → WSL, 가상 머신 플랫폼 기능 활성화 → Ubuntu 설치 → VERSION 2 확인
- 작업 위치는 WSL 내부 파일 시스템의 `~/devops`

### Git / GitHub

- `add`는 저장이 아니라 다음 커밋에 넣을 변경을 고르는 단계(staging)
- `commit`으로 버전 기록, `push`로 GitHub 업로드
- 브랜치는 특정 커밋을 가리키는 이름. 브랜치를 나누면 작업끼리 서로 영향 없음

## 새로 배운 명령어

```bash
pwd
ls -l / ls -a          # -a로 숨김 폴더 .git 확인
mkdir / cd / rmdir / rm
mv hi.txt hello.txt    # 같은 폴더 안에서는 이름 변경
cat
echo "Hello" > a.txt   # 덮어쓰기
echo "Hi" >> a.txt     # 이어쓰기, 파일 없으면 새로 생성
chmod 755 s.txt
whoami
sudo apt update
sudo !!                # 직전 명령을 sudo로 재실행
!ls                    # ls로 시작한 최근 명령 재실행
```

```bash
git config --global user.name "이름"
git config --global init.defaultBranch main
git init
git status
git add text.txt
git commit -m "first commit"
git log --oneline
git switch -c hi       # 브랜치 생성 + 이동
git switch main
git diff main hi
git log --oneline --all --graph
```

```bash
gh auth login
gh repo create devops --public --source=. --remote=origin --push
gh repo view --web
gh auth logout         # 학교 PC 사용 후 필수
```

## 실습 기록

- `fa2fb14` first commit: `week02/text.txt` 생성 후 add, commit으로 첫 커밋
- `7028242` second commit: `>>`로 내용 추가 실습 (아래 트러블슈팅 참고)
- `e619bd5` hello: 브랜치 실습. main에서 `hello` 커밋 → `hi` 브랜치에서 `hi`로 수정 후 커밋 → main 복귀 후 `cat` 결과 `hello` 유지 확인. GitHub에는 main만 푸시해서 레포에서도 `hello`
- `5ab6f5a` README add: README 작성 실습 (내용은 이번 정리로 보완)

## 트러블슈팅

- 상황: `week02/text.txt`에 한 줄을 추가하려 했는데 레포 루트에 `text.txt`가 새로 생성됨
- 원인: `week02`로 이동하지 않고 `~/devops`에서 `echo "..." >> text.txt` 실행. `>>`는 대상 파일이 없으면 새로 만들기 때문에 에러 없이 진행됨
- 배운 점: 파일을 다루는 명령 전에 `pwd`로 현재 위치 확인
