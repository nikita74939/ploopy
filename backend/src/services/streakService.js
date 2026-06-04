import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { createNotification } from './notificationService.js';

const select = 'id, user_id, current_streak, longest_streak, last_active_date, freeze_used_this_week';

function todayJakarta() {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jakarta' }).format(new Date());
}

function diffDays(a, b) {
  return Math.round((Date.parse(b) - Date.parse(a)) / 86400000);
}

export async function getStreak(userId) {
  const { data, error } = await supabaseAdmin.from('streaks').select(select).eq('user_id', userId).maybeSingle();
  if (error) throw httpError(500, error.message);
  if (data) return data;
  const created = await supabaseAdmin.from('streaks').insert({ user_id: userId }).select(select).single();
  if (created.error) throw httpError(500, created.error.message);
  return created.data;
}

export async function checkInStreak(userId) {
  const streak = await getStreak(userId);
  const today = todayJakarta();
  if (streak.last_active_date === today) return streak;

  let current = 1;
  if (streak.last_active_date && diffDays(streak.last_active_date, today) === 1) current = Number(streak.current_streak ?? 0) + 1;

  const payload = { current_streak: current, longest_streak: Math.max(current, streak.longest_streak ?? 0), last_active_date: today };
  const { data, error } = await supabaseAdmin.from('streaks').update(payload).eq('user_id', userId).select(select).single();
  if (error) throw httpError(500, error.message);
  await createNotification({
    userId,
    input: {
      title: 'Streak diperbarui',
      description: `Streak kamu sekarang ${data.current_streak} hari.`,
      tag: 'streak_update',
      refId: data.id,
      refType: 'streak',
    },
  });
  return data;
}
