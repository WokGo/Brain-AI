#!/bin/bash
set -e

# 🎨 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 색상 초기화

# 📂 실행 경로 자동 감지
BASE_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
TMP_DIR="$BASE_DIR/tmp"

clear
echo -e "${GREEN}🧠 Brain-AI 통합 관리 콘솔 (v5.4 — Auto Permission Edition)${NC}"
echo "--------------------------------------------------------------"

# 🔧 하위 스크립트 권한 자동 설정
echo -e "${YELLOW}🔧 실행 권한 설정 중...${NC}"
find "$TMP_DIR" -type f -name "*.sh" -exec chmod +x {} \;
echo -e "${GREEN}✅ 모든 Shell Script 실행 권한 부여 완료${NC}"
echo ""

# 🔍 존재 확인
if [ ! -d "$TMP_DIR" ]; then
  echo -e "${RED}❌ tmp 디렉토리가 없습니다. ${NC}"
  exit 1
fi

echo "실행할 작업을 선택하세요:"
echo ""
echo "1) 🏗️  전체 스택 구축 (Docker Compose)"
echo "2) 🧩  DB 서버 수동 실행 (SQLite)"
echo "3) 🔐  HTTPS 인증 (paradocs.click)"
echo "4) 🚀  CI/CD 자동 배포 (GitHub Actions)"
echo "5) ⚙️  CI/CD 자동 배포 (Jenkins)"
echo "6) 🧹  전체 정리 (모든 컨테이너/이미지/DB 삭제)"
echo "7) ❌  종료"
echo "--------------------------------------------------------------"

read -p "선택 번호 입력: " choice

case $choice in
  1)
    echo -e "${YELLOW}🧱 Docker Compose 기반 Brain-AI 스택 설치 중...${NC}"
    bash "$TMP_DIR/setup_brainai_stack.sh"
    ;;
  2)
    echo -e "${YELLOW}🧩 DB 서버 실행 중...${NC}"
    bash "$TMP_DIR/db_server.sh"
    ;;
  3)
    echo -e "${YELLOW}🔐 HTTPS 설정 (Route53 + Certbot)...${NC}"
    bash "$TMP_DIR/setup_paradocs.sh"
    ;;
  4)
    echo -e "${YELLOW}🚀 GitHub Actions CI/CD 파이프라인 생성 중...${NC}"
    mkdir -p "$BASE_DIR/.github/workflows"
    cat > "$BASE_DIR/.github/workflows/brainai-ci.yml" <<'EOF'
name: Brain-AI CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Docker
        uses: docker/setup-buildx-action@v3

      - name: Build and run stack
        run: |
          docker-compose down
          docker-compose up --build -d
          docker ps -a
EOF
    echo -e "${GREEN}✅ GitHub Actions 설정 완료 (.github/workflows/brainai-ci.yml)${NC}"
    ;;
  5)
    echo -e "${YELLOW}⚙️  Jenkins 파이프라인 구성 중...${NC}"
    cat > "$BASE_DIR/Jenkinsfile" <<'EOF'
pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { git branch: 'main', url: 'https://github.com/<YOUR_ID>/Brain-AI.git' }
    }
    stage('Build Docker Image') {
      steps { sh 'docker-compose build' }
    }
    stage('Deploy Containers') {
      steps { sh 'docker-compose up -d' }
    }
  }
  post {
    success { echo '✅ Brain-AI 재배포 완료' }
    failure { echo '❌ 배포 실패' }
  }
}
EOF
    echo -e "${GREEN}✅ Jenkinsfile 생성 완료${NC}"
    ;;
  6)
    echo -e "${RED}🧹 전체 클린업 중...${NC}"
    docker-compose down -v || true
    docker system prune -af || true
    rm -rf "$BASE_DIR/data"/*.db
    echo -e "${GREEN}✅ 정리 완료${NC}"
    ;;
  7)
    echo -e "${YELLOW}👋 종료합니다.${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}⚠️  잘못된 선택입니다.${NC}"
    ;;
esac

echo -e "${GREEN}✅ 모든 작업이 완료되었습니다.${NC}"
