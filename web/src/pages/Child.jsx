import React,{useEffect,useRef,useState} from "react";
import { api } from "../api";
import ChatBox from "../components/ChatBox";
export default function Child({user}) {
  const [msgs,setMsgs]=useState([]);
  const recRef=useRef(null);
  useEffect(()=>{load();},[]);
  async function load(){const {data}=await api.get("/messages");setMsgs(data);}
  function startSTT(){
    const SR=window.SpeechRecognition||window.webkitSpeechRecognition;
    if(!SR) return alert("음성인식 미지원 브라우저");
    const r=new SR(); r.lang="ko-KR";
    r.onresult=async e=>{
      const text=e.results[0][0].transcript;
      await api.post("/messages",{user_id:user.id,role:user.role,text});
      load();
    }; r.start(); recRef.current=r;
  }
  function speak(t){const u=new SpeechSynthesisUtterance(t);u.lang="ko-KR";speechSynthesis.speak(u);}
  return(<div style={{padding:20}}>
    <h2>🧠 Brain AI — 아동</h2>
    <div style={{margin:"10px 0"}}>
      <button onClick={startSTT}>🎤 말하기</button>
      <button onClick={()=>speak("괜찮아요. 천천히 말해도 돼요.")}>🗣️ 위로</button>
    </div>
    <ChatBox user={user}/>
    <ul>{msgs.slice(0,20).map(m=>(<li key={m.id}>[{m.role}] {m.text} ({m.mood_score?.toFixed?.(2)})</li>))}</ul>
  </div>);
}
