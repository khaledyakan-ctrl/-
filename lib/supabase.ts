import { createClient, SupabaseClient } from '@supabase/supabase-js';
let client: SupabaseClient | null = null;
export function db() {
 if (!client) {
  const url=process.env.NEXT_PUBLIC_SUPABASE_URL, key=process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if(!url||!key) throw new Error('يرجى إعداد متغيرات Supabase في ملف .env.local');
  client=createClient(url,key,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}});
 }
 return client;
}
export const money=(v:number|string|null|undefined)=>'$'+Number(v||0).toLocaleString('en-US',{minimumFractionDigits:2,maximumFractionDigits:2});
export const date=(v:string|null|undefined)=>v?new Date(v).toLocaleDateString('ar-LB'): '—';
export const num=(v:any)=>Number(v)||0;
