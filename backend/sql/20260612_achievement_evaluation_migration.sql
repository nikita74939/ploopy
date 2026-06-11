CREATE TABLE IF NOT EXISTS public.achievement_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  amount integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_achievement_events_user_type
ON public.achievement_events(user_id, event_type);

CREATE INDEX IF NOT EXISTS idx_achievement_events_user_created
ON public.achievement_events(user_id, created_at DESC);

DELETE FROM public.user_achievements ua
USING public.user_achievements duplicate
WHERE ua.user_id = duplicate.user_id
  AND ua.achievement_id = duplicate.achievement_id
  AND ua.ctid > duplicate.ctid;

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_achievements_unique_user_achievement
ON public.user_achievements(user_id, achievement_id);
