import nodemailer from "nodemailer";
import axios from "axios";

export async function sendSMS({to,body}) {
  const {TWILIO_ACCOUNT_SID,TWILIO_AUTH_TOKEN,TWILIO_FROM} = process.env;
  if(!TWILIO_ACCOUNT_SID||!TWILIO_AUTH_TOKEN||!TWILIO_FROM) return {ok:false};
  const url = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`;
  const auth = {username:TWILIO_ACCOUNT_SID,password:TWILIO_AUTH_TOKEN};
  const data = new URLSearchParams({From:TWILIO_FROM,To:to,Body:body}).toString();
  await axios.post(url,data,{auth,headers:{"Content-Type":"application/x-www-form-urlencoded"}});
  return {ok:true};
}

export async function sendMail({to,subject,html}) {
  const {SMTP_HOST,SMTP_PORT,SMTP_USER,SMTP_PASS,MAIL_FROM} = process.env;
  if(!SMTP_HOST||!SMTP_USER||!SMTP_PASS) return {ok:false};
  const t = nodemailer.createTransport({
    host:SMTP_HOST, port:Number(SMTP_PORT||587), secure:false,
    auth:{user:SMTP_USER,pass:SMTP_PASS}
  });
  await t.sendMail({from:MAIL_FROM||SMTP_USER,to,subject,html});
  return {ok:true};
}
