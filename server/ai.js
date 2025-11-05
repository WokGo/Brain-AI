const NEG_KEYS = ["아파","싫어","무서워","그만","힘들어","불편"];
const PANIC_KEYS = ["도와줘","위험","위급","살려줘"];
export function analyze(text=""){
  const t = String(text||"").trim();
  if(!t) return { mood:0, intent:"neutral", triggers:[] };
  let score = 0, triggers=[];
  NEG_KEYS.forEach(k=>{ if(t.includes(k)){score-=0.3; triggers.push(k);} });
  PANIC_KEYS.forEach(k=>{ if(t.includes(k)){score-=0.7; triggers.push(k);} });
  let intent="neutral";
  if(triggers.some(k=>PANIC_KEYS.includes(k))) intent="help";
  else if(triggers.length) intent="need_break";
  if(score>1) score=1; if(score<-1) score=-1;
  return { mood:score, intent, triggers };
}
