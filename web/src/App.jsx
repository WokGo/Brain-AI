import React,{useEffect,useState} from "react";
import Child from "./pages/Child"; import Parent from "./pages/Parent";
import { api } from "./api";
export default function App(){
  const [user,setUser]=useState(null); const [role,setRole]=useState("child");
  useEffect(()=>{init();},[role]);
  async function init(){
    const {data}=await api.post("/users",{role,name:role==="child"?"아동":"보호자",consent:true});
    setUser(data);
  }
  if(!user) return <div>초기화 중...</div>;
  return(<div>
    <div style={{padding:10,borderBottom:"1px solid #eee"}}>
      <b>Brain AI</b> — <select value={role} onChange={e=>setRole(e.target.value)}>
        <option value="child">아동</option><option value="parent">보호자</option>
      </select>
    </div>
    {role==="child"?<Child user={user}/>:<Parent user={user}/>}
  </div>);
}
