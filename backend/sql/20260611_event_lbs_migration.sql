alter table public.events
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists place_id text,
  add column if not exists address text;

create index if not exists idx_events_coordinates
  on public.events (latitude, longitude)
  where latitude is not null and longitude is not null;

alter table public.events
  drop constraint if exists events_offline_coordinates_required;

alter table public.events
  add constraint events_offline_coordinates_required
  check (
    is_online = true
    or (latitude is not null and longitude is not null)
  ) not valid;

alter table public.events
  drop constraint if exists events_coordinates_range;

alter table public.events
  add constraint events_coordinates_range
  check (
    (latitude is null or latitude between -90 and 90)
    and (longitude is null or longitude between -180 and 180)
  );
