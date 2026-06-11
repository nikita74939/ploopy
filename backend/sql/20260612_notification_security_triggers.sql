ALTER TABLE public.notifications
ADD COLUMN IF NOT EXISTS sender_user_id uuid REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE public.notifications
ADD COLUMN IF NOT EXISTS deep_link text;

ALTER TABLE public.notifications
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_notifications_user_id
ON public.notifications(user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read
ON public.notifications(user_id, is_read);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
ON public.notifications(user_id, created_at DESC);
