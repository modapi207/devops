#!/bin/bash
cd "$(dirname $0)" || exit 1
if ! command -v python3 >/dev/nyll 2>&1; then
	echo "python3을 먼저 설치하세요." >&2
	exit 1
fi
export MODEL="qwen3:0.6b"
exec ./start.sh
