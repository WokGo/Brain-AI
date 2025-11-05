import React,{useEffect,useState} from "react";
import { io } from "socket.io-client";
import { api } from "../api";
import MoodDial from "../components/MoodDial";
export default function Parent({user}){
  const [msgs,setMsgs]=useState([]); const [mood,setMood]=useState(0); const [alerts,setAlerts]=useState([]);
  useEffect(()=>{
    load();
    const s=io("/",{path:"/socket.io",query:{role:"parent"}});
    s.on("message:new",m=>{setMsgs(v=>[m,...v]); if(typeof m.mood_score==="number") setMood(m.mood_score);});
    s.on("alert:new",a=>setAlerts(v=>[a,...v]));
    return()=>s.disconnect();
  },[]);
  async function load(){const {data}=await api.get("/messages");setMsgs(data);}
  return(<div style={{padding:20}}>
    <h2>👪 보호자 대시보드</h2>
    <div>현재 기분<MoodDial score={mood}/></div>
    <h3>📣 경보</h3><ul>{alerts.map((a,i)=>(<li key={i}>[{a.reason}] {a.text}</li>))}</ul>
    <h3>📝 로그</h3><ul>{msgs.slice(0,50).map(m=>(<li key={m.id}>[{m.role}] {m.text}</li>))}</ul>
  </div>);
}
