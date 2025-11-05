import React,{useState} from "react";
import { api } from "../api";
export default function ChatBox({user}) {
  const [t,setT]=useState("");
  async function send(){ if(!t.trim())return; await api.post("/messages",{user_id:user.id,role:user.role,text:t}); setT(""); }
  return(<div style={{display:"flex",gap:8}}>
    <input value={t} onChange={e=>setT(e.target.value)} placeholder="메시지 입력" style={{flex:1,padding:10}}/>
    <button onClick={send}>전송</button>
  </div>);
}
