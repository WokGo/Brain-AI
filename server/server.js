import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import http from "http";
import { Server as SocketIOServer } from "socket.io";
import { initDB } from "./db.js";
import { analyze } from "./ai.js";
import { sendSMS, sendMail } from "./alerts.js";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());
const server = http.createServer(app);
const io = new SocketIOServer(server,{cors:{origin:"*"}});
const dbp = initDB();

function emitToParents(ev,p){ io.to("parents").emit(ev,p); }

io.on("connection",s=>{
  if(s.handshake.query.role==="parent") s.join("parents");
});

app.post("/api/users",async(req,res)=>{
  const {role,name,phone,email,consent=false}=req.body||{};
  const db=await dbp;
  await db.run("INSERT INTO users(role,name,phone,email,consent) VALUES(?,?,?,?,?)",role,name,phone,email,consent?1:0);
  const u=await db.get("SELECT * FROM users ORDER BY id DESC LIMIT 1");
  res.json(u);
});

app.post("/api/messages",async(req,res)=>{
  const {user_id,role,text}=req.body||{};
  const db=await dbp;
  const {mood,intent,triggers}=analyze(text);
  await db.run("INSERT INTO messages(user_id,role,text,mood_score,intent) VALUES(?,?,?,?,?)",user_id,role,text,mood,intent);
  const m=await db.get("SELECT * FROM messages ORDER BY id DESC LIMIT 1");
  emitToParents("message:new",m);
  if(mood<=-0.6||intent==="help"){
    const parent=await db.get("SELECT * FROM users WHERE role='parent' LIMIT 1");
    if(parent){
      const reason=intent==="help"?"panic":"negative_mood";
      const msg=`[BrainAI] ${reason} 감지: "${text}" (${mood.toFixed(2)})`;
      if(parent.phone) await sendSMS({to:parent.phone,body:msg});
      if(parent.email) await sendMail({to:parent.email,subject:"[BrainAI] 경보",html:`<pre>${msg}</pre>`});
      await db.run("INSERT INTO alerts(user_id,type,reason,payload) VALUES(?,?,?,?)",parent.id,"notify",reason,text);
      emitToParents("alert:new",{reason,text,mood,intent,triggers});
    }
  }
  res.json({ok:true,message:m});
});

app.get("/api/messages",async(req,res)=>{
  const db=await dbp;
  const rows=await db.all("SELECT * FROM messages ORDER BY created_at DESC LIMIT 100");
  res.json(rows);
});

server.listen(process.env.PORT||4000,()=>console.log("BrainAI API on 4000"));
