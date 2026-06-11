import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { createActivity } from './activityService.js';
import { unlockEligibleAchievements } from './achievementService.js';
import { checkInStreak } from './streakService.js';

const studySelect =
  'id, user_id, start_time, end_time, duration_minutes, created_at';
const MIN_STREAK_MINUTES = 5;

function dayRange(date) {
  const start = new Date(date);
  if (Number.isNaN(start.getTime())) throw httpError(400, 'Tanggal tidak valid.');
  start.setHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return { start, end };
}

export async function getStudySessions({ userId, date }) {
  let query = supabaseAdmin
    .from('study_sessions')
    .select(studySelect)
    .eq('user_id', userId)
    .order('start_time', { ascending: false });

  if (date) {
    const { start, end } = dayRange(date);
    query = query.gte('start_time', start.toISOString()).lt('start_time', end.toISOString());
  }

  const { data, error } = await query;
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function startStudySession({ userId }) {
  const { data, error } = await supabaseAdmin
    .from('study_sessions')
    .insert({
      user_id: userId,
      start_time: new Date().toISOString(),
      duration_minutes: 0,
    })
    .select(studySelect)
    .single();

  if (error) throw httpError(500, error.message);
  return data;
}

export async function endStudySession({ userId, sessionId, durationMinutes }) {
  if (!Number.isInteger(durationMinutes) || durationMinutes < 0) {
    throw httpError(400, 'Durasi belajar tidak valid.');
  }

  const existing = await supabaseAdmin
    .from('study_sessions')
    .select(studySelect)
    .eq('id', sessionId)
    .eq('user_id', userId)
    .maybeSingle();

  if (existing.error) throw httpError(500, existing.error.message);
  if (!existing.data) throw httpError(404, 'Sesi belajar tidak ditemukan.');

  const { data, error } = await supabaseAdmin
    .from('study_sessions')
    .update({
      end_time: new Date().toISOString(),
      duration_minutes: durationMinutes,
    })
    .eq('id', sessionId)
    .eq('user_id', userId)
    .select(studySelect)
    .maybeSingle();

  if (error) throw httpError(500, error.message);
  if (!data) throw httpError(404, 'Sesi belajar tidak ditemukan.');
  if (!existing.data.end_time && durationMinutes >= MIN_STREAK_MINUTES) {
    const streak = await checkInStreak(userId);
    const [totalStudyMinutes, studySessionCount] = await Promise.all([
      getTotalStudyMinutes(userId),
      getCompletedStudySessionCount(userId),
    ]);

    await Promise.all([
      unlockEligibleAchievements({
        userId,
        metrics: {
          currentStreak: streak.current_streak ?? 0,
          totalStudyMinutes,
          studySessionCount,
        },
      }),
      createActivity({
        userId,
        input: {
          text: `Menyelesaikan sesi fokus ${durationMinutes} menit.`,
        },
      }),
    ]);
  }
  return data;
}

export async function getTodayStudyMinutes(userId) {
  const { start, end } = dayRange(new Date().toISOString());
  const { data, error } = await supabaseAdmin
    .from('study_sessions')
    .select('duration_minutes')
    .eq('user_id', userId)
    .gte('start_time', start.toISOString())
    .lt('start_time', end.toISOString());

  if (error) throw httpError(500, error.message);
  return (data ?? []).reduce((total, row) => total + (row.duration_minutes ?? 0), 0);
}

export async function getStudyMinutesByMonth({ userId, year, month }) {
  const y = Number.parseInt(year, 10);
  const m = Number.parseInt(month, 10);
  if (!Number.isInteger(y) || !Number.isInteger(m) || m < 1 || m > 12) {
    throw httpError(400, 'Bulan belajar tidak valid.');
  }

  const start = new Date(y, m - 1, 1);
  const end = new Date(y, m, 1);
  const { data, error } = await supabaseAdmin
    .from('study_sessions')
    .select('start_time, duration_minutes')
    .eq('user_id', userId)
    .gte('start_time', start.toISOString())
    .lt('start_time', end.toISOString());

  if (error) throw httpError(500, error.message);

  return (data ?? []).reduce((days, row) => {
    const day = new Date(row.start_time).getDate();
    days[day] = (days[day] ?? 0) + (row.duration_minutes ?? 0);
    return days;
  }, {});
}

async function getTotalStudyMinutes(userId) {
  const { data, error } = await supabaseAdmin
    .from('study_sessions')
    .select('duration_minutes')
    .eq('user_id', userId)
    .not('end_time', 'is', null);

  if (error) throw httpError(500, error.message);
  return (data ?? []).reduce((total, row) => total + (row.duration_minutes ?? 0), 0);
}

async function getCompletedStudySessionCount(userId) {
  const { count, error } = await supabaseAdmin
    .from('study_sessions')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .not('end_time', 'is', null)
    .gte('duration_minutes', MIN_STREAK_MINUTES);

  if (error) throw httpError(500, error.message);
  return count ?? 0;
}
