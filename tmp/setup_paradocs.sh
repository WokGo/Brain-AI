#!/bin/bash
# =====================================================
# paradocs.click - HTTPS 자동 구성 스크립트
# nginx + certbot (Let's Encrypt)
# =====================================================

DOMAIN="paradocs.click"
EMAIL="admin@${DOMAIN}"

echo "🔧 업데이트 및 기본 패키지 설치..."
sudo apt update -y
sudo apt install -y nginx certbot python3-certbot-nginx ufw

echo "🧱 방화벽 설정 (80, 443 허용)"
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP' 2>/dev/null || true
sudo ufw --force enable

echo "🧩 nginx 가상호스트 생성..."
sudo bash -c "cat > /etc/nginx/sites-available/${DOMAIN} <<'EOF'
server {
    listen 80;
    server_name paradocs.click www.paradocs.click;

    location / {
        proxy_pass https://ubiquitous-carnival-v6jw7wv55gqq555-5173.app.github.dev;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_page 404 /404.html;
}
EOF"

sudo ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo "🔐 Let's Encrypt SSL 인증서 발급 중..."
sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --agree-tos -m ${EMAIL} --non-interactive

echo "♻️ 자동 갱신 크론 등록 확인..."
sudo systemctl list-timers | grep certbot || sudo systemctl enable certbot.timer

echo "✅ HTTPS 적용 완료!"
echo "브라우저에서 https://${DOMAIN} 접속 시 Codespaces 앱이 안전하게 프록시됩니다."
