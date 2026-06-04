create table if not exists public.study_sessions (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  start_time timestamptz not null,
  end_time timestamptz,
  duration_minutes integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists study_sessions_user_start_idx
  on public.study_sessions (user_id, start_time desc);

alter table public.study_sessions enable row level security;

drop policy if exists "Users can read their own study sessions" on public.study_sessions;
create policy "Users can read their own study sessions"
  on public.study_sessions for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own study sessions" on public.study_sessions;
create policy "Users can insert their own study sessions"
  on public.study_sessions for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own study sessions" on public.study_sessions;
create policy "Users can update their own study sessions"
  on public.study_sessions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own study sessions" on public.study_sessions;
create policy "Users can delete their own study sessions"
  on public.study_sessions for delete
  using (auth.uid() = user_id);
