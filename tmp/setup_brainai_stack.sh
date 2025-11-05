#!/bin/bash
set -e

echo "🌐 Brain-AI 통합 환경 자동 구축 스크립트 (v5.3)"
BASE_DIR=$(pwd)
mkdir -p $BASE_DIR/{web,server,data}

echo "📦 web, server, data 디렉토리 초기화 완료"

# -----------------------------
# 1️⃣ Web (React/Vite)
# -----------------------------
cat > $BASE_DIR/web/Dockerfile <<'EOF'
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]
EOF

# -----------------------------
# 2️⃣ Server (Node/Express)
# -----------------------------
cat > $BASE_DIR/server/Dockerfile <<'EOF'
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# -----------------------------
# 3️⃣ DB (SQLite + 경로 설정)
# -----------------------------
cat > $BASE_DIR/server/db.js <<'EOF'
import sqlite3 from "sqlite3";
import { open } from "sqlite";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const DB_PATH = process.env.DB_PATH || path.resolve(__dirname, "../data/brainai.db");

export async function initDB() {
  const db = await open({ filename: DB_PATH, driver: sqlite3.Database });
  await db.exec(`
    PRAGMA journal_mode=WAL;

    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      role TEXT CHECK(role IN ('child','parent')) NOT NULL,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      consent BOOLEAN DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      role TEXT,
      text TEXT,
      mood_score REAL,
      intent TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS alerts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      type TEXT,
      reason TEXT,
      payload TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  console.log(\`✅ SQLite DB initialized at: \${DB_PATH}\`);
  return db;
}
EOF

# -----------------------------
# 4️⃣ docker-compose.yml
# -----------------------------
cat > $BASE_DIR/docker-compose.yml <<'EOF'
version: "3.8"

services:
  web:
    build: ./web
    container_name: brainai_web
    ports:
      - "5173:5173"
    environment:
      - VITE_API_URL=http://localhost:3000
    depends_on:
      - server
    command: ["npm", "run", "dev"]
    restart: unless-stopped

  server:
    build: ./server
    container_name: brainai_server
    ports:
      - "3000:3000"
    volumes:
      - ./data:/app/data
    environment:
      - NODE_ENV=development
      - DB_PATH=/app/data/brainai.db
    restart: unless-stopped

  dbview:
    image: linuxserver/sqlitebrowser:latest
    container_name: brainai_db_browser
    ports:
      - "8080:3000"
    volumes:
      - ./data:/config
    restart: unless-stopped
EOF

# -----------------------------
# 5️⃣ README.md (간단 가이드)
# -----------------------------
cat > $BASE_DIR/README.md <<'EOF'
# 🧠 Brain-AI v5.3 — Full Stack Setup

## 실행
```bash
bash setup_brainai_stack.sh
