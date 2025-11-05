import React from "react";
export default function MoodDial({score=0}) {
  const pct=Math.round(((score+1)/2)*100);
  const color=score<-0.6?"#e74c3c":score<0?"#f1c40f":"#2ecc71";
  return(<div>
    <div style={{width:220,height:18,background:"#eee",borderRadius:9}}>
      <div style={{width:`${pct}%`,height:"100%",background:color,borderRadius:9}}/>
    </div>
    <small style={{color}}>{score.toFixed(2)}</small>
  </div>);
}
