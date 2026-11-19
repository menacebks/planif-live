-- Planif'Live : schéma Supabase
-- À exécuter une fois dans Supabase > SQL Editor > New query.

create table if not exists public.events (
  id          uuid primary key default gen_random_uuid(),
  type        text not null check (type in ('live','battle','irl','collab','qa','defi')),
  title       text not null check (char_length(title) between 1 and 80),
  host        text not null check (char_length(host) between 2 and 31),
  start_at    timestamptz not null,
  dur         int  not null default 60 check (dur between 15 and 600),
  place       text check (char_length(place) <= 120),
  tags        text check (char_length(tags) <= 80),
  descr       text check (char_length(descr) <= 400),
  cap         int  check (cap is null or cap between 1 and 100000),
  creator     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);

create table if not exists public.rsvps (
  event_id    uuid not null references public.events(id) on delete cascade,
  uid         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  handle      text not null check (char_length(handle) between 2 and 31),
  created_at  timestamptz not null default now(),
  primary key (event_id, uid)
);

create index if not exists events_start_idx on public.events (start_at);

-- Sécurité : tout le monde lit, chacun ne modifie que ce qu'il a créé.
alter table public.events enable row level security;
alter table public.rsvps  enable row level security;

drop policy if exists "events lisibles"  on public.events;
drop policy if exists "events creation"  on public.events;
drop policy if exists "events suppression" on public.events;
create policy "events lisibles"    on public.events for select using (true);
create policy "events creation"    on public.events for insert to authenticated
  with check (creator = auth.uid() and start_at > now() - interval '1 hour');
create policy "events suppression" on public.events for delete to authenticated using (creator = auth.uid());

drop policy if exists "rsvps lisibles"   on public.rsvps;
drop policy if exists "rsvps creation"   on public.rsvps;
drop policy if exists "rsvps suppression" on public.rsvps;
create policy "rsvps lisibles"    on public.rsvps for select using (true);
create policy "rsvps creation"    on public.rsvps for insert to authenticated with check (uid = auth.uid());
create policy "rsvps suppression" on public.rsvps for delete to authenticated using (uid = auth.uid());

-- Anti-abus : 10 événements max par personne et par jour.
create or replace function public.limite_events() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from events where creator = new.creator and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Too many events today';
  end if;
  return new;
end $$;
drop trigger if exists limite_events on public.events;
create trigger limite_events before insert on public.events for each row execute function public.limite_events();

-- Places limitées : refuse une inscription quand l'événement est complet.
create or replace function public.verifie_places() returns trigger
language plpgsql security definer set search_path = public as $$
declare c int;
begin
  select cap into c from events where id = new.event_id for update;
  if c is not null and (select count(*) from rsvps where event_id = new.event_id) >= c then
    raise exception 'Evenement complet';
  end if;
  return new;
end $$;
drop trigger if exists verifie_places on public.rsvps;
create trigger verifie_places before insert on public.rsvps for each row execute function public.verifie_places();

-- Temps réel : la page se met à jour quand quelqu'un publie ou s'inscrit.
do $$ begin
  alter publication supabase_realtime add table public.events, public.rsvps;
exception when duplicate_object then null; end $$;
