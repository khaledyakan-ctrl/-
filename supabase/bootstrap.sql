-- RUN AFTER CREATING THREE USERS under Authentication > Users.
-- Replace the example UUID values with real auth.users IDs.
-- Run ONCE in Supabase SQL Editor (privileged), never from the browser.
insert into public.businesses (id,name) values ('00000000-0000-4000-8000-000000000001','لقمة هنيّة – مطبخ ست الكل') on conflict (id) do nothing;
-- Uncomment, substitute REAL UUIDs, and execute each line:
-- insert into public.members (business_id,user_id,full_name,role) values ('00000000-0000-4000-8000-000000000001','REPLACE-WITH-USER-UUID','الأم','admin');
-- insert into public.members (business_id,user_id,full_name,role) values ('00000000-0000-4000-8000-000000000001','REPLACE-WITH-USER-UUID','الجدة','production');
-- insert into public.members (business_id,user_id,full_name,role) values ('00000000-0000-4000-8000-000000000001','REPLACE-WITH-USER-UUID','الصديقة','operations');
