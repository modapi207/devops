# 4주차 - 자동화와 협업 / 네트워크

셸 스크립트로 백업 자동화, 브랜치와 PR로 협업 흐름 실습, 네트워크 명령으로 내 PC를 웹 서버로 운영

## 오늘 배운 내용

- 파이프(`|`): 앞 명령의 출력을 뒤 명령의 입력으로 연결. `grep`, `wc -l`과 묶어서 로그 분석
- 셸 스크립트의 변수, 인자(`$1`, `$#`), 조건문(`[ -f ]`, `[ -d ]`, `-eq`)
- `.gitignore`: 실행할 때마다 생기는 결과물(백업 파일)은 Git에서 제외
- 협업 흐름: 브랜치 → 커밋/푸시 → PR → Merge. 같은 줄을 다르게 고치면 Conflict, 사람이 골라서 해결
- IP는 컴퓨터를 찾는 주소, 포트는 그 컴퓨터 안의 서비스를 구분하는 번호. DNS는 도메인을 IP로 바꿔 줌

## 새로 배운 명령어

```bash
find . -type f -name "*.sh"
grep -n "ERROR" server.log
cat server.log | grep ERROR | wc -l
grep ERROR server.log > errors.txt
head -2 diary.txt / tail -1 diary.txt / wc -l diary.txt
tar -czf backups/파일.tar.gz test     # 압축 백업
tar -xzf 파일.tar.gz -C restore-check # 복원
sed -i 's/찾을문구/바꿀문구/' backup.sh
gh pr create --base main
gh pr merge
```

```bash
ip addr
ping -c 4 8.8.8.8
dig cs.inhatc.ac.kr +short
curl -I https://google.com
ss -tlnp | grep 8080
python3 -m http.server 8080
```

## 실습 기록

`week04/`

- `backup.sh`: 폴더를 날짜+PID 이름으로 압축 백업하고 `backups/backup.log`에 기록. 로그 기능은 `feature/backup-log` 브랜치에서 작업해 PR #1로 Merge
- `test/`: `diary.txt`(heredoc), `server.log`·`errors.txt`(grep), `var.sh`(변수), `greet.sh`(인자), `check.sh`(파일/디렉터리 조건문)
- `site/index.html`: `python3 -m http.server 8080`으로 띄운 웹 페이지
- [완료] 로그 기록을 남기고 해결 후 Merge
- Conflict 실습: main은 `로그기록`, `fix/message`는 `[완료] 로그 기록`으로 같은 줄을 고쳐 PR #9에서 충돌 → 

## 트러블슈팅

- `.gitignore`를 `week04/` 안에 두었더니 무시가 안 됨
  - 원인: 하위 폴더의 `.gitignore`는 그 폴더 기준으로 경로를 읽어서, `week04/backups/`가 `week04/week04/backups/`로 해석됨
  - 해결: 레포 루트로 이동
- main에 바로 push했더니 rejected
  - 원인: GitHub 웹에서 고친 커밋이 로컬에 없었음. `Your branch is up to date`는 마지막 fetch 기준이라 믿으면 안 됨
  - 해결: `git fetch`로 확인 후 `git pull --ff-only`, 작업은 브랜치에서 하고 PR로 반영
- `server.log`, `index.html`에 실행 권한(755)이 붙음
  - 원인: 윈도우 폴더(`/mnt/c`)의 파일을 `cp`로 복사하면 실행 권한이 따라옴
  - 해결: `chmod -x`. 실행할 파일(.sh)만 실행 권한을 둠
- `gh pr view --web`이 열리지 않음
  - 원인: WSL에 브라우저를 여는 프로그램이 없음
  - 해결: `sudo apt install wslu` 또는 주소를 직접 열기
