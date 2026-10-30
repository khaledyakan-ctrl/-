'use client';
import {useState} from 'react';
import {db} from '../../lib/supabase';
export default function Login(){ const [email,setEmail]=useState(''),[password,setPassword]=useState(''),[error,setError]=useState(''),[loading,setLoading]=useState(false);
 async function submit(e:React.FormEvent){e.preventDefault();setError('');setLoading(true);try{const {error}=await db().auth.signInWithPassword({email,password});if(error)throw error;location.href='/';}catch(e:any){setError(e.message)}finally{setLoading(false)}}
 return <main className="login"><form className="panel login-card" onSubmit={submit}><img src="/logo.webp" className="login-logo" alt="لقمة هنيّة – مطبخ ست الكل"/><h1>لقمة هنيّة</h1><p>مطبخ ست الكل</p><p>نظام إدارة المأكولات البيتية</p><label>البريد الإلكتروني<input required type="email" value={email} onChange={e=>setEmail(e.target.value)}/></label><label>كلمة المرور<input required type="password" value={password} onChange={e=>setPassword(e.target.value)}/></label>{error&&<p className="error">{error}</p>}<button disabled={loading}>{loading?'جارٍ الدخول...':'تسجيل الدخول'}</button><small>الحسابات تُنشأ من مسؤول النظام فقط</small></form></main>
}
