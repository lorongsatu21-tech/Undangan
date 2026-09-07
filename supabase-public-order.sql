-- Jalankan SEKALI di Supabase SQL Editor setelah database/RLS dasar sudah dibuat.
-- Membuat checkout publik tanpa membuka tabel customers/orders/order_items ke anon.

create or replace function public.create_public_order(
  p_name text,
  p_phone text,
  p_event_date date,
  p_event_location text,
  p_notes text,
  p_product_id uuid,
  p_quantity integer,
  p_unit_price numeric
) returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_customer uuid;
  v_order uuid;
  v_order_number text;
  v_product record;
  v_total numeric;
begin
  if length(trim(p_name)) < 2 or length(trim(p_phone)) < 6 then raise exception 'Data pelanggan tidak valid'; end if;
  if p_quantity <= 0 or p_unit_price < 0 then raise exception 'Jumlah/harga tidak valid'; end if;
  select id, product_code, name into v_product from public.products where id=p_product_id and is_active=true;
  if not found then raise exception 'Produk tidak tersedia'; end if;
  -- Validasi harga terhadap tabel harga agar browser tidak bisa memalsukan harga.
  if not exists(select 1 from public.product_prices where product_id=p_product_id and quantity=p_quantity and unit_price=p_unit_price) then raise exception 'Harga tidak valid'; end if;
  v_total := p_quantity*p_unit_price;
  insert into public.customers(name,phone) values(trim(p_name),trim(p_phone)) returning id into v_customer;
  v_order_number := 'LS-INV-'||to_char(now(),'YYYYMMDD-HH24MISS')||'-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,4));
  insert into public.orders(order_number,customer_id,event_date,event_location,status,subtotal,total,notes)
  values(v_order_number,v_customer,p_event_date,p_event_location,'baru',v_total,v_total,p_notes) returning id into v_order;
  insert into public.order_items(order_id,product_id,product_code,product_name,quantity,unit_price,subtotal)
  values(v_order,p_product_id,v_product.product_code,v_product.name,p_quantity,p_unit_price,v_total);
  return v_order_number;
end;$$;

grant execute on function public.create_public_order(text,text,date,text,text,uuid,integer,numeric) to anon, authenticated;

create or replace function public.get_public_order_status(p_order_number text)
returns table(order_number text,status text,total numeric,created_at timestamptz)
language sql
security definer
stable
set search_path = ''
as $$
 select o.order_number,o.status,o.total,o.created_at from public.orders o where o.order_number=p_order_number limit 1;
$$;
grant execute on function public.get_public_order_status(text) to anon, authenticated;
