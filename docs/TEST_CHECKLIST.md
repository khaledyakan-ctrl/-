# Manual acceptance tests

- Admin can log in; unknown account is refused by membership check.
- Production role can edit ingredients/recipes/batches but cannot edit financial expenses.
- Operations role can create a customer, order, payment; cannot edit equipment expenses.
- Create a product with recipe; enter purchase price and confirm unit cost snapshot.
- Record production 10 units, deliver an order of 3, confirm inventory shows 7.
- Edit order items and ensure correct lines (requires DELETE policy on order_items).
- New order delivery fee 3 and actual driver cost 2 appear separately.
- Add cash partial payment; outstanding decreases.
- Add Whish transfer with sender number; not counted until marked verified.
- View customer receipt; print/save PDF; open WhatsApp prefilled message.
- Cancel unfulfilled order and confirm it is excluded from completed revenue.
- Enter freezer as equipment expense, verify excluded from operating expenses.
- Reject cross-business foreign keys; verify RLS when signed into another business.
- Verify no keys except Supabase publishable key are exposed to the browser.
