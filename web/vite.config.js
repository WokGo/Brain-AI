import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Codespaces 자동 감지
const serverHost = process.env.CODESPACE_NAME
  ? `https://${process.env.CODESPACE_NAME}-4000.app.github.dev`
  : "http://localhost:4000";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/api": {
        target: serverHost,
        changeOrigin: true,
        secure: false,
      },
      "/socket.io": {
        target: serverHost,
        ws: true,
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
