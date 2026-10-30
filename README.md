# لقمة هنيّة – مطبخ ست الكل — Loqma Haniyeh – Matbakh Sett El Kell

Private **Arabic RTL** Next.js 15 / React 19 dashboard for a small Lebanese frozen-food family business. Built for three authenticated staff members; no public ordering.

## Modules

- Dashboard, customers, suppliers, ingredients, purchasing, products, ingredient-based recipes
- Production batches, finished freezer inventory, stock adjustments, freezer temperature logs
- Manual sales orders (WhatsApp/Instagram/phone), order lines, discounts, delivery fees and actual driver costs
- Cash and Whish Money payments with sender/receiver number and explicit Whish confirmation
- Arabic receipts (browser print/save as PDF) and prefilled WhatsApp text sharing
- Expenses vs equipment, partner capital/withdrawals, revenue/COGS/operating-profit summaries
- Arabic responsive mobile UI; private Supabase Auth and row-level security

## Set up in a NEW Supabase project

1. Create a Supabase project (do not run this SQL against MonitorCore).
2. In SQL Editor, run `supabase/migrations/20261029000100_initial.sql`.
3. In Supabase Authentication > Users, create the 3 accounts manually using their real emails and passwords. Disable open signups. Confirm their email addresses in the dashboard as appropriate.
4. Run `supabase/bootstrap.sql` to create the business. Copy the real auth.users UUIDs into **uncommented** member INSERT statements from that file and execute those statements. The initial business UUID is `00000000-0000-4000-8000-000000000001`.
5. In Supabase project settings, copy your **Project URL** and **publishable (or legacy anon) key**. Never put a service role/secret key into NEXT_PUBLIC variables.
6. Copy `.env.example` to `.env.local`, populate both keys, run `npm install` and `npm run dev`.
7. Open `http://localhost:3000`, log in, enter project name and Whish number in Settings, then create ingredients, products, recipes, production, customers and orders.
8. Deploy to Vercel and configure the same `NEXT_PUBLIC_` environment variables. Configure Supabase Auth URL settings for the production origin if needed.

## Critical behavior

- Order amounts: sum(quantity × recorded selling price) − discount + delivery fee.
- Product/recipe costing: latest weighted-average input purchase prices are used to estimate recipe cost, combined with packaging and other cost. Each order line captures a **unit-cost snapshot** when created.
- Production batch unit cost is editable, and if omitted uses the current estimated recipe cost.
- Finished inventory is derived from batches + adjustments − **delivered** orders. Rejected/cancelled orders don't consume stock.
- Cash payments count as received immediately; Whish transfers must be confirmed manually before they count. Multiple payments per order are supported.
- Operating profit = revenue on delivered orders − recorded order-line COGS − delivery costs on delivered orders − general non-equipment expenses. Equipment investment is reported separately, not as ordinary operating expense.
- Receipts are commercial order/payment summaries, **not tax invoices**. PDF export uses browser printing. WhatsApp opens a prefilled text message; PDF attachments are shared manually.

## Limits and safety before production use

This is a usable **V1 starter implementation**, not an independently audited accounting system. **No backend transactional order-posting RPC** is implemented: saving an order and its items uses separate calls, so interrupted saves can leave incomplete orders. Multi-user concurrency could oversell inventory; make sure order edits, negative stock and payments are reviewed. Production batches currently do not automatically subtract raw-ingredient inventory. Product COGS uses snapshots, not FIFO per batch; cost/quantity changes can require reconciliation. No automatic tax, payroll, depreciation, currency conversion or precise cash settlement accounting. Monthly profit and cashflow are therefore operational estimates, not audited financial statements. Validate home-food permits, freezer conditions and expiry controls independently.

RLS protects business row isolation, verifies cross-business foreign keys and restricts writes by `admin`, `production`, and `operations`. All members can read shared business data; sensitive financial access can be restricted further if necessary. Client-side stock checking is advisory, not a server-side transaction guarantee. No public user registration is provided.

**First deployment checklist:** test login on all 3 accounts, order creation/edit, Whish pending/confirm, partial payments, receipt print and WhatsApp on actual phones; test concurrency/cancellation with small fake orders. Enable Supabase automatic backups, MFA for admin, and HTTPS. Do not store customer data in open demo projects.

## Brand update (30 October 2026)

- Logo: `public/logo.webp` (latest generated circular culinary badge).
- Favicon: `app/icon.png`.
- New brand everywhere: **لقمة هنيّة – مطبخ ست الكل**.
- Color theme: burgundy / cream / olive-inspired neutrals.
- Make sure the Arabic wording in generated logo art is visually proofread before commercial printing.
- Seasonal maamoul can be added as a product with its own recipe; `products.active` is available in SQL, but the V1 UI does not yet expose an active/seasonal toggle.
