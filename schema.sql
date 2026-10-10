-- Already applied to the live Supabase project. Keep for re-creating the backend elsewhere.
-- Admin email: ajibadei75@gmail.com (change in is_admin() if needed).
create table if not exists attendees(id text primary key,data jsonb not null,created_at timestamptz not null default now());
create table if not exists settings(id text primary key,data jsonb not null,created_at timestamptz not null default now());
create table if not exists downloads_log(id text primary key,data jsonb not null,created_at timestamptz not null default now());
create index if not exists attendees_created_idx on attendees(created_at desc);
create or replace function is_admin() returns boolean language sql stable set search_path=public as
$$ select lower(coalesce(auth.jwt()->>'email',''))='ajibadei75@gmail.com' $$;
alter table attendees enable row level security; alter table settings enable row level security; alter table downloads_log enable row level security;
create policy att_insert on attendees for insert to anon with check(data ? 'name' and data ? 'email' and not (data ? 'approved') and pg_column_size(data)<2000 and id=lower(data->>'email') and length(data->>'name')>1 and (data->>'email') ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$');
create policy att_admin on attendees for all to authenticated using(is_admin()) with check(is_admin());
-- flier and certificate templates are NOT public: they are served only through get_assets() to approved attendees
create policy set_read on settings for select to anon,authenticated using(id not in ('flier','certificate'));
create policy set_admin on settings for all to authenticated using(is_admin()) with check(is_admin());
create policy dl_insert on downloads_log for insert to anon,authenticated with check(pg_column_size(data)<500);
create policy dl_admin on downloads_log for select to authenticated using(is_admin());
create function check_email(e text) returns table(name text,approved boolean) language sql security definer set search_path=public as
$$ select data->>'name',coalesce((data->>'approved')::boolean,false) from attendees where id=lower(trim(e)) $$;
create function get_assets(e text) returns jsonb language plpgsql security definer set search_path=public as $$
declare a attendees; cert jsonb; fl jsonb;
begin
 select * into a from attendees where id=lower(trim(e));
 if not found or coalesce((a.data->>'approved')::boolean,false)=false then return null; end if;
 select data into fl from settings where id='flier'; select data into cert from settings where id='certificate';
 if coalesce((cert->>'released')::boolean,false)=false then cert:=null; end if;
 return jsonb_build_object('flier',fl,'certificate',cert);
end $$;
create function seat_count() returns int language sql security definer set search_path=public as $$ select count(*)::int from attendees $$;
revoke execute on function check_email(text),get_assets(text),seat_count() from public;
grant execute on function check_email(text),get_assets(text),seat_count() to anon,authenticated;
create function enforce_capacity() returns trigger language plpgsql security definer set search_path=public as $$
declare cap int;
begin
 select coalesce((data->>'capacity')::int,0) into cap from settings where id='event';
 if cap>0 and (select count(*) from attendees)>=cap then raise exception 'Registration is full'; end if;
 return new;
end $$;
revoke execute on function enforce_capacity() from public,anon,authenticated;
create trigger cap_trg before insert on attendees for each row execute function enforce_capacity();
