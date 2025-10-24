#!/bin/bash

# --- 스크립트: Git add, commit, push 자동화 ---

# 스크립트 실행 중 오류가 발생하면 즉시 중단
set -e

# 1. 커밋 메시지를 입력받았는지 확인
if [ -z "$1" ]; then
  echo "🚨 오류: 커밋 메시지를 입력해야 합니다."
  echo "👉 사용법: ./gitpush.sh \"여기에 커밋 메시지 입력\""
  exit 1
fi

# 2. 현재 브랜치 이름 가져오기
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
  echo "🚨 오류: Git 브랜치를 찾을 수 없습니다. Git 저장소가 맞는지 확인하세요."
  exit 1
fi

echo "🔄 현재 브랜치: $CURRENT_BRANCH"

# 3. Git 명령 실행
echo "1. git add ."
git add .

echo "2. git commit -m \"$1\""
git commit -m "$1"

echo "3. git push origin $CURRENT_BRANCH"
git push origin "$CURRENT_BRANCH"

echo "✅ 푸시 완료!"