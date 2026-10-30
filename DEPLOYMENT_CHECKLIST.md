# Deployment checklist — لقمة هنيّة – مطبخ ست الكل

1. Create a fresh Supabase project (NEVER run schema on MonitorCore database).
2. Run `supabase/migrations/20261029000100_initial.sql` in Supabase SQL Editor.
3. Create three Supabase Auth users, then edit and execute the commented member rows in `supabase/bootstrap.sql` with real Auth UUIDs. Run the initial business INSERT first.
4. Add the environment variables from `.env.example` in Vercel project settings (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`). Use only publishable/anon key, never service role.
5. Run `npm install`, `npm run typecheck`, `npm run build` locally/CI, and fix any errors before deployment. This deliverable could not complete npm installation in this environment.
6. Deploy only after success; log in as each user; test orders, receipts/printing, cash, Whish verification, delivery fees, PDF/WhatsApp, and mobile layout.
7. TEST WITH FAKE DATA ONLY. The current application is a pre-production starter: saving orders and order items is not atomic, stock concurrency is not protected, and ingredient consumption from production is not automatically posted. These limitations must be fixed before live operations or financial reliance.
8. Confirm brand name/trademark rights and proofread the AI-generated logo text before commercial use.
