'use client';
import {useEffect,useState} from 'react';
import {db} from '../lib/supabase';
import Dashboard from '../components/Dashboard';
export default function Home(){const [ready,setReady]=useState(false),[err,setErr]=useState('');useEffect(()=>{try{db().auth.getUser().then(({data,error})=>{if(error||!data.user){location.replace('/login');return;}setReady(true)}).catch(e=>setErr(e.message))}catch(e:any){setErr(e.message)}},[]);if(err)return <div className="center-error">{err}<p>انسخ .env.example إلى .env.local وأدخل إعدادات المشروع.</p></div>;return ready?<Dashboard/>:<main className="loading">جارٍ تحميل المنصة...</main>}
