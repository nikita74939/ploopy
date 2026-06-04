create extension if not exists "uuid-ossp" with schema extensions;

create table if not exists public.users (
  id uuid primary key default extensions.uuid_generate_v4(),
  name text not null,
  email text not null unique,
  password_hash text,
  bio text,
  avatar_url text,
  joined_at timestamptz default now(),
  biometric_enabled boolean default false
);

create table if not exists public.app_settings (
  id uuid primary key default extensions.uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade unique,
  dark_mode boolean default false,
  language text default 'id',
  notif_enabled boolean default true,
  app_lock_enabled boolean default false
);

create table if not exists public.streaks (
  id uuid primary key default extensions.uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade unique,
  current_streak integer default 0,
  longest_streak integer default 0,
  last_active_date date,
  freeze_used_this_week integer default 0
);

create table if not exists public.achievements (
  id uuid primary key default extensions.uuid_generate_v4(),
  name text not null,
  description text,
  badge_icon text,
  condition_type text,
  condition_value integer
);

create table if not exists public.user_achievements (
  id uuid primary key default extensions.uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  achievement_id uuid references public.achievements(id) on delete cascade,
  unlocked_at timestamptz default now(),
  unique(user_id, achievement_id)
);

create table if not exists public.schedules (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  location text,
  description text,
  link text,
  color bigint not null default 4294923776,
  icon_name text default 'event',
  repeat_type text not null default 'None',
  repeat_until timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  subject text,
  deadline timestamptz not null,
  details text,
  color bigint not null default 4294923776,
  icon_name text default 'task',
  is_pinned boolean not null default false,
  is_completed boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default extensions.uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  text text,
  location text,
  achievement_id uuid references public.achievements(id) on delete set null,
  created_at timestamptz default now()
);

create table if not exists public.activity_images (
  id uuid primary key default extensions.uuid_generate_v4(),
  activity_id uuid references public.activities(id) on delete cascade,
  image_url text,
  order_index integer default 0
);

create table if not exists public.activity_likes (
  id uuid primary key default extensions.uuid_generate_v4(),
  activity_id uuid references public.activities(id) on delete cascade,
  user_id uuid references public.users(id) on delete cascade,
  liked_at timestamptz default now(),
  unique(activity_id, user_id)
);

create table if not exists public.activity_comments (
  id uuid primary key default extensions.uuid_generate_v4(),
  activity_id uuid references public.activities(id) on delete cascade,
  user_id uuid references public.users(id) on delete cascade,
  content text not null,
  created_at timestamptz default now()
);

create table if not exists public.friendships (
  id uuid primary key default extensions.uuid_generate_v4(),
  requester_id uuid references public.users(id) on delete cascade,
  addressee_id uuid references public.users(id) on delete cascade,
  status text default 'pending',
  created_at timestamptz default now(),
  unique(requester_id, addressee_id)
);

create table if not exists public.events (
  id uuid primary key default extensions.uuid_generate_v4(),
  creator_id uuid references public.users(id) on delete cascade,
  name text not null,
  icon text,
  color text,
  event_date timestamptz,
  location text,
  is_online boolean default false,
  max_participants integer,
  description text,
  created_at timestamptz default now(),
  price numeric(12,2) default 0 not null
);

create table if not exists public.event_participants (
  id uuid primary key default extensions.uuid_generate_v4(),
  event_id uuid references public.events(id) on delete cascade,
  user_id uuid references public.users(id) on delete cascade,
  joined_at timestamptz default now(),
  unique(event_id, user_id)
);

create table if not exists public.notifications (
  id uuid primary key default extensions.uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  title text not null,
  description text,
  tag text,
  is_read boolean default false,
  created_at timestamptz default now(),
  ref_id uuid,
  ref_type text
);

insert into public.achievements (name, description, badge_icon, condition_type, condition_value)
select * from (values
  ('On Fire', 'Belajar 3 hari berturut-turut', 'local_fire_department', 'streak_day', 3),
  ('Unstoppable', 'Belajar 7 hari berturut-turut', 'whatshot', 'streak_day', 7),
  ('Discipline Master', 'Belajar 30 hari berturut-turut', 'military_tech', 'streak_day', 30),
  ('Task Starter', 'Selesaikan 1 task', 'check_circle', 'completed_task', 1),
  ('Task Crusher', 'Selesaikan 10 task', 'task_alt', 'completed_task', 10),
  ('First Friend', 'Tambah 1 teman', 'person_add', 'friend_count', 1),
  ('Social Butterfly', 'Tambah 10 teman', 'groups', 'friend_count', 10),
  ('Planner Rookie', 'Buat 1 jadwal', 'event_note', 'schedule_count', 1),
  ('Routine Builder', 'Buat 10 jadwal', 'calendar_month', 'schedule_count', 10)
) as seed(name, description, badge_icon, condition_type, condition_value)
where not exists (select 1 from public.achievements);

alter table public.users enable row level security;
alter table public.app_settings enable row level security;
alter table public.streaks enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.schedules enable row level security;
alter table public.tasks enable row level security;
alter table public.activities enable row level security;
alter table public.activity_images enable row level security;
alter table public.activity_likes enable row level security;
alter table public.activity_comments enable row level security;
alter table public.friendships enable row level security;
alter table public.events enable row level security;
alter table public.event_participants enable row level security;
alter table public.notifications enable row level security;
