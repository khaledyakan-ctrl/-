-- Loqma Haniyeh – Matbakh Sett El Kell: private family business. Run on a NEW Supabase project.
create extension if not exists pgcrypto;
create schema if not exists private;
create table public.businesses(id uuid primary key default gen_random_uuid(),name text not null default 'لقمة هنيّة – مطبخ ست الكل',whish_number text,phone text,created_at timestamptz not null default now());
create table public.members(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),user_id uuid not null unique references auth.users(id) on delete cascade,full_name text not null,role text not null check(role in ('admin','production','operations')),created_at timestamptz default now());
create function private.is_member(b uuid) returns boolean language sql stable security definer set search_path = '' as $$select exists(select 1 from public.members m where m.business_id=b and m.user_id=(select auth.uid()))$$;
create function private.is_admin(b uuid) returns boolean language sql stable security definer set search_path = '' as $$select exists(select 1 from public.members m where m.business_id=b and m.user_id=(select auth.uid()) and m.role='admin')$$;
revoke all on function private.is_member(uuid) from public,anon;
revoke all on function private.is_admin(uuid) from public,anon;
grant usage on schema private to authenticated;
grant execute on function private.is_member(uuid),private.is_admin(uuid) to authenticated;
create table public.customers(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),name text not null,phone text,address text,area text,notes text,created_at timestamptz default now());
create table public.suppliers(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),name text not null,phone text,notes text,created_at timestamptz default now());
create table public.ingredients(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),name text not null,unit text not null default 'كغ',opening_qty numeric(14,3) not null default 0,opening_unit_cost numeric(14,4) not null default 0,min_qty numeric(14,3) not null default 0,created_at timestamptz default now(),check(opening_qty>=0),check(opening_unit_cost>=0));
create table public.purchases(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),ingredient_id uuid not null references public.ingredients(id),supplier_id uuid references public.suppliers(id),quantity numeric(14,3) not null check(quantity>0),total_cost numeric(14,2) not null check(total_cost>=0),purchased_on date not null default current_date,notes text,created_at timestamptz default now());
create table public.products(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),name text not null,unit text not null default 'علبة',selling_price numeric(14,2) not null default 0,packaging_cost numeric(14,2) not null default 0,other_unit_cost numeric(14,2) not null default 0,low_stock_qty numeric(14,3) not null default 0,active boolean not null default true,created_at timestamptz default now(),check(selling_price>=0),check(packaging_cost>=0));
create table public.recipe_items(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),product_id uuid not null references public.products(id) on delete cascade,ingredient_id uuid not null references public.ingredients(id),quantity numeric(14,4) not null check(quantity>0),unique(product_id,ingredient_id));
create table public.production_batches(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),product_id uuid not null references public.products(id),quantity numeric(14,3) not null check(quantity>0),unit_cost numeric(14,4) not null default 0 check(unit_cost>=0),produced_on date not null default current_date,expires_on date,freezer_location text,notes text,created_at timestamptz default now(),check(expires_on is null or expires_on>=produced_on));
create table public.orders(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),order_no bigint generated always as identity,customer_id uuid references public.customers(id),status text not null default 'new' check(status in ('new','preparing','ready','out_for_delivery','delivered','cancelled')),ordered_on date not null default current_date,delivery_on date,delivery_type text not null default 'delivery' check(delivery_type in ('delivery','pickup')),delivery_address text,delivery_area text,delivery_fee numeric(14,2) not null default 0,delivery_cost numeric(14,2) not null default 0,discount numeric(14,2) not null default 0,notes text,created_at timestamptz not null default now(),check(delivery_fee>=0 and delivery_cost>=0 and discount>=0));
create table public.order_items(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),order_id uuid not null references public.orders(id) on delete cascade,product_id uuid not null references public.products(id),quantity numeric(14,3) not null check(quantity>0),unit_price numeric(14,2) not null check(unit_price>=0),unit_cost numeric(14,4) not null default 0 check(unit_cost>=0));
create table public.payments(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),order_id uuid not null references public.orders(id),amount numeric(14,2) not null check(amount>0),method text not null check(method in ('cash','whish')),sender_phone text,receiver_phone text,reference text,verified boolean not null default false,paid_on date not null default current_date,notes text,created_at timestamptz not null default now(),check(method<>'whish' or sender_phone is not null));
create table public.expenses(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),title text not null,category text not null default 'operating' check(category in ('operating','equipment','delivery','other')),amount numeric(14,2) not null check(amount>=0),spent_on date not null default current_date,notes text,created_at timestamptz default now());
create table public.partner_entries(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),partner_name text not null,entry_type text not null check(entry_type in ('capital','withdrawal','labor')),amount numeric(14,2) not null check(amount>0),entry_on date not null default current_date,notes text,created_at timestamptz default now());
create table public.freezer_checks(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),checked_on timestamptz not null default now(),freezer_name text not null default 'المجمّد',temperature_c numeric(6,2) not null,notes text);
create table public.stock_adjustments(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),product_id uuid not null references public.products(id),quantity_delta numeric(14,3) not null check(quantity_delta<>0),reason text not null,adjusted_on date not null default current_date);
-- Protect business ownership; do not expose unlimited authenticated users to other businesses.
alter table public.businesses enable row level security;
create policy "member reads business" on public.businesses for select to authenticated using (private.is_member(id));
create policy "admin updates business" on public.businesses for update to authenticated using(private.is_admin(id)) with check(private.is_admin(id));
alter table public.members enable row level security;
create policy "member reads members" on public.members for select to authenticated using(private.is_member(business_id));
-- Member provisioning only by the Supabase admin/service-side SQL, never client application.
do $$ declare t text; begin foreach t in array array['customers','suppliers','ingredients','purchases','products','recipe_items','production_batches','orders','order_items','payments','expenses','partner_entries','freezer_checks','stock_adjustments'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('create policy "member select" on public.%I for select to authenticated using(private.is_member(business_id))',t);
 execute format('create policy "member insert" on public.%I for insert to authenticated with check(private.is_member(business_id))',t);
 execute format('create policy "member update" on public.%I for update to authenticated using(private.is_member(business_id)) with check(private.is_member(business_id))',t);
 end loop; end $$;
-- Child rows must always reference entities from the same business, even across permitted edits.
create function private.assert_same_business() returns trigger language plpgsql set search_path = '' as $$
declare fk text; target uuid; b uuid;
begin
 for fk in select unnest(case TG_TABLE_NAME
 when 'purchases' then array['ingredient_id','supplier_id']
 when 'recipe_items' then array['product_id','ingredient_id']
 when 'production_batches' then array['product_id']
 when 'orders' then array['customer_id']
 when 'order_items' then array['order_id','product_id']
 when 'payments' then array['order_id']
 when 'stock_adjustments' then array['product_id'] else array[]::text[] end)
 loop
 execute format('select ($1).%I',fk) into target using new;
 if target is not null then
  execute format('select business_id from public.%I where id=$1',case fk when 'ingredient_id' then 'ingredients' when 'supplier_id' then 'suppliers' when 'product_id' then 'products' when 'customer_id' then 'customers' when 'order_id' then 'orders' end) into b using target;
  if b is distinct from new.business_id then raise exception 'Cross-business reference not allowed'; end if;
 end if;
 end loop;
 return new;
end $$;
do $$ declare t text; begin foreach t in array array['purchases','recipe_items','production_batches','orders','order_items','payments','stock_adjustments'] loop execute format('create trigger check_business before insert or update on public.%I for each row execute function private.assert_same_business()',t);end loop;end $$;
-- Immutable ownership protects cross-business reassignments.
create function private.prevent_business_change() returns trigger language plpgsql set search_path = '' as $$begin if new.business_id<>old.business_id then raise exception 'Business cannot be changed';end if; return new;end $$;
do $$ declare t text; begin foreach t in array array['members','customers','suppliers','ingredients','purchases','products','recipe_items','production_batches','orders','order_items','payments','expenses','partner_entries','freezer_checks','stock_adjustments'] loop execute format('create trigger immutable_business before update on public.%I for each row execute function private.prevent_business_change()',t);end loop;end $$;
-- No deletion policies: history must be preserved. Reversals / adjustments are preferred.
grant select,insert,update on public.customers,public.suppliers,public.ingredients,public.purchases,public.products,public.recipe_items,public.production_batches,public.orders,public.order_items,public.payments,public.expenses,public.partner_entries,public.freezer_checks,public.stock_adjustments to authenticated;
grant select on public.members,public.businesses to authenticated;
grant update on public.businesses to authenticated;
-- Identity sequence needed for order insertion.
grant usage,select on all sequences in schema public to authenticated;

-- Allow replacing order line items while editing an order.
create policy "member delete order items" on public.order_items for delete to authenticated using(private.is_member(business_id));
grant delete on public.order_items to authenticated;
-- Role-based write permissions enforced in PostgreSQL (not just the UI).
create function private.can_write(b uuid, resource text) returns boolean language sql stable security definer set search_path='' as $$
select exists(select 1 from public.members m where m.business_id=b and m.user_id=(select auth.uid()) and (
 m.role='admin' or (m.role='production' and resource=any(array['ingredients','purchases','products','recipe_items','production_batches','freezer_checks','stock_adjustments','suppliers']))
 or (m.role='operations' and resource=any(array['orders','order_items','customers','payments','freezer_checks']))
))$$;
revoke all on function private.can_write(uuid,text) from public,anon;
grant execute on function private.can_write(uuid,text) to authenticated;
do $$ declare t text; begin foreach t in array array['customers','suppliers','ingredients','purchases','products','recipe_items','production_batches','orders','order_items','payments','expenses','partner_entries','freezer_checks','stock_adjustments'] loop
 execute format('drop policy "member insert" on public.%I',t);
 execute format('drop policy "member update" on public.%I',t);
 execute format('create policy "authorized insert" on public.%I for insert to authenticated with check(private.can_write(business_id,%L))',t,t);
 execute format('create policy "authorized update" on public.%I for update to authenticated using(private.can_write(business_id,%L)) with check(private.can_write(business_id,%L))',t,t,t);
 end loop;end $$;
drop policy "member delete order items" on public.order_items;
create policy "authorized delete order items" on public.order_items for delete to authenticated using(private.can_write(business_id,'order_items'));
