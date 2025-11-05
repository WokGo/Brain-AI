# db_server.sh
#!/bin/bash
DB_PATH="./server/brainai.db"
echo "🧠 SQLite DB 서버 실행 중... (파일: $DB_PATH)"
sqlite3 "$DB_PATH"
