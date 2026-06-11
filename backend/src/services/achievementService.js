import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { createNotification } from './notificationService.js';

const achievementSelect =
  'id, name, description, badge_icon, condition_type, condition_value';

export async function getAllAchievements() {
  const { data, error } = await supabaseAdmin
    .from('achievements')
    .select(achievementSelect)
    .order('condition_type', { ascending: true })
    .order('condition_value', { ascending: true });

  if (error) {
    throw httpError(500, error.message);
  }

  return data ?? [];
}

export async function getUserAchievements(userId) {
  const { data, error } = await supabaseAdmin
    .from('user_achievements')
    .select(`id, user_id, achievement_id, unlocked_at, achievements(${achievementSelect})`)
    .eq('user_id', userId)
    .order('unlocked_at', { ascending: false });

  if (error) {
    throw httpError(500, error.message);
  }

  return data ?? [];
}

export async function unlockUserAchievement({ userId, achievementId }) {
  const { data: achievement, error: achievementError } = await supabaseAdmin
    .from('achievements')
    .select('id, name')
    .eq('id', achievementId)
    .maybeSingle();

  if (achievementError) {
    throw httpError(500, achievementError.message);
  }

  if (!achievement) {
    throw httpError(404, 'Achievement tidak ditemukan.');
  }

  const { data: existing, error: existingError } = await supabaseAdmin
    .from('user_achievements')
    .select('id, user_id, achievement_id, unlocked_at')
    .eq('user_id', userId)
    .eq('achievement_id', achievementId)
    .maybeSingle();

  if (existingError) {
    throw httpError(500, existingError.message);
  }

  if (existing) {
    return existing;
  }

  const { data, error } = await supabaseAdmin
    .from('user_achievements')
    .insert({
      user_id: userId,
      achievement_id: achievementId,
    })
    .select('id, user_id, achievement_id, unlocked_at')
    .single();

  if (error) {
    if (error.code === '23505') {
      const { data: duplicate, error: duplicateError } = await supabaseAdmin
        .from('user_achievements')
        .select('id, user_id, achievement_id, unlocked_at')
        .eq('user_id', userId)
        .eq('achievement_id', achievementId)
        .maybeSingle();
      if (duplicateError) throw httpError(500, duplicateError.message);
      if (duplicate) return duplicate;
    }
    throw httpError(500, error.message);
  }

  await createNotification({
    userId,
    input: {
      title: 'Achievement baru',
      description: `Kamu mendapat achievement ${achievement.name}.`,
      tag: 'achievement_unlocked',
      refId: achievementId,
      refType: 'achievement',
    },
  });

  return data;
}

export async function unlockEligibleAchievements({ userId, metrics }) {
  return evaluateUserAchievements({ userId, extraMetrics: metrics });
}

export async function evaluateUserAchievements({ userId, triggerType = null, extraMetrics = {} }) {
  const achievements = await getAllAchievements();
  const metrics = await collectAchievementMetrics(userId, extraMetrics);
  const unlocked = [];

  for (const achievement of achievements) {
    const currentValue = achievementMetricValue(achievement.condition_type, metrics);
    const targetValue = Number(achievement.condition_value ?? 0);
    if (currentValue < targetValue) continue;

    const userAchievement = await unlockUserAchievement({
      userId,
      achievementId: achievement.id,
    });
    unlocked.push(userAchievement);
  }

  return { triggerType, metrics, unlocked };
}

export async function getAchievementStatus(userId) {
  const [achievements, userAchievements, metrics] = await Promise.all([
    getAllAchievements(),
    getUserAchievements(userId),
    collectAchievementMetrics(userId),
  ]);
  const unlockedMap = new Map(userAchievements.map((item) => [item.achievement_id, item]));

  return achievements.map((achievement) => {
    const currentValue = Math.max(0, achievementMetricValue(achievement.condition_type, metrics));
    const targetValue = Number(achievement.condition_value ?? 0);
    const unlocked = unlockedMap.get(achievement.id);
    return {
      ...achievement,
      unlocked: Boolean(unlocked),
      unlocked_at: unlocked?.unlocked_at ?? null,
      progress: {
        current: currentValue,
        target: targetValue,
        percent: targetValue > 0 ? Math.min(1, currentValue / targetValue) : (unlocked ? 1 : 0),
      },
    };
  });
}

export async function trackAchievementEvent({ userId, eventType, amount = 1 }) {
  if (!eventType || typeof eventType !== 'string') {
    throw httpError(400, 'eventType wajib diisi.');
  }
  const normalizedAmount = Number.parseInt(amount, 10);
  const safeAmount = Number.isFinite(normalizedAmount) && normalizedAmount > 0 ? normalizedAmount : 1;
  const { error } = await supabaseAdmin
    .from('achievement_events')
    .insert({
      user_id: userId,
      event_type: normalizeConditionType(eventType),
      amount: safeAmount,
    });

  if (error) throw httpError(500, error.message);
  return evaluateUserAchievements({
    userId,
    triggerType: eventType,
  });
}

async function collectAchievementMetrics(userId, extraMetrics = {}) {
  const [
    activityCount,
    completedTasks,
    createdTasks,
    scheduleCreated,
    acceptedFriends,
    streak,
    studyRows,
    studySessionCount,
    eventJoined,
    eventCreated,
    trackedEvents,
  ] = await Promise.all([
    countRows('activities', (query) => query.eq('user_id', userId)),
    countRows('tasks', (query) => query.eq('user_id', userId).eq('is_completed', true)),
    countRows('tasks', (query) => query.eq('user_id', userId)),
    countRows('schedules', (query) => query.eq('user_id', userId)),
    countRows('friendships', (query) => query.eq('status', 'accepted').or(`requester_id.eq.${userId},addressee_id.eq.${userId}`)),
    getStreakMetrics(userId),
    getStudyRows(userId),
    countRows('study_sessions', (query) => query.eq('user_id', userId).not('end_time', 'is', null).gte('duration_minutes', 5)),
    countRows('event_participants', (query) => query.eq('user_id', userId)),
    countRows('events', (query) => query.eq('creator_id', userId)),
    getTrackedEventMetrics(userId),
  ]);

  const totalStudyMinutes = studyRows.reduce((sum, row) => sum + Number(row.duration_minutes ?? 0), 0);
  const earlyStudy = studyRows.filter((row) => hourInJakarta(row.start_time) >= 4 && hourInJakarta(row.start_time) < 9).length;
  const nightStudy = studyRows.filter((row) => {
    const hour = hourInJakarta(row.start_time);
    return hour >= 21 || hour < 4;
  }).length;

  return {
    activityCount,
    postCount: activityCount,
    completedTasks,
    createdTasks,
    taskCount: createdTasks,
    scheduleCreated,
    acceptedFriends,
    currentStreak: streak.currentStreak,
    longestStreak: streak.longestStreak,
    totalStudyMinutes,
    totalFocusMinutes: totalStudyMinutes,
    studySessionCount,
    focusSessionCount: studySessionCount,
    earlyStudy,
    nightStudy,
    eventJoined,
    eventCreated,
    ...trackedEvents,
    ...extraMetrics,
  };
}

function achievementMetricValue(conditionType, metrics) {
  switch (normalizeConditionType(conditionType)) {
    case 'activity_count':
    case 'activity_created':
    case 'post_count':
    case 'social_post_count':
      return metrics.activityCount ?? metrics.postCount ?? 0;
    case 'first_activity':
    case 'first_post':
      return metrics.activityCount ?? metrics.postCount ?? 0;
    case 'streak_day':
    case 'streak_days':
      return metrics.currentStreak ?? 0;
    case 'study_minutes':
    case 'total_study_minutes':
    case 'total_focus_minutes':
    case 'focus_minutes':
      return metrics.totalStudyMinutes ?? 0;
    case 'study_session_count':
    case 'focus_session_count':
      return metrics.studySessionCount ?? 0;
    case 'completed_tasks':
    case 'task_completed':
    case 'task_done':
    case 'completed_task_count':
      return metrics.completedTasks ?? 0;
    case 'created_tasks':
    case 'task_created':
    case 'task_count':
      return metrics.createdTasks ?? 0;
    case 'accepted_friends':
    case 'friend_count':
    case 'friends_count':
    case 'first_friend':
      return metrics.acceptedFriends ?? 0;
    case 'schedule_created':
    case 'schedule_count':
    case 'planner_count':
    case 'routine_count':
      return metrics.scheduleCreated ?? 0;
    case 'scanner_used':
    case 'scanner_count':
    case 'scan_count':
      return metrics.scannerUsed ?? 0;
    case 'ocr_used':
    case 'ocr_count':
      return metrics.ocrUsed ?? 0;
    case 'converter_used':
    case 'converter_count':
      return metrics.converterUsed ?? 0;
    case 'currency_converter_used':
      return metrics.currencyConverterUsed ?? 0;
    case 'timezone_converter_used':
      return metrics.timezoneConverterUsed ?? 0;
    case 'ai_plan_used':
    case 'ai_daily_plan_used':
    case 'ai_plan_created':
      return metrics.aiPlanUsed ?? 0;
    case 'early_study':
    case 'early_bird':
      return metrics.earlyStudy ?? 0;
    case 'night_study':
    case 'night_owl':
      return metrics.nightStudy ?? 0;
    case 'event_joined':
      return metrics.eventJoined ?? 0;
    case 'event_created':
      return metrics.eventCreated ?? 0;
    default:
      return -1;
  }
}

function normalizeConditionType(conditionType) {
  return String(conditionType ?? '').trim().toLowerCase();
}

async function countRows(table, apply) {
  let query = supabaseAdmin.from(table).select('id', { count: 'exact', head: true });
  query = apply(query);
  const { count, error } = await query;
  if (error) throw httpError(500, error.message);
  return count ?? 0;
}

async function getStreakMetrics(userId) {
  const { data, error } = await supabaseAdmin
    .from('streaks')
    .select('current_streak, longest_streak')
    .eq('user_id', userId)
    .maybeSingle();
  if (error) throw httpError(500, error.message);
  return {
    currentStreak: Number(data?.current_streak ?? 0),
    longestStreak: Number(data?.longest_streak ?? 0),
  };
}

async function getStudyRows(userId) {
  const { data, error } = await supabaseAdmin
    .from('study_sessions')
    .select('start_time, duration_minutes')
    .eq('user_id', userId)
    .not('end_time', 'is', null);
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

async function getTrackedEventMetrics(userId) {
  const { data, error } = await supabaseAdmin
    .from('achievement_events')
    .select('event_type, amount')
    .eq('user_id', userId);

  if (error) {
    if (/achievement_events|relation/i.test(error.message)) {
      return {};
    }
    throw httpError(500, error.message);
  }

  return (data ?? []).reduce((metrics, row) => {
    const key = trackedMetricKey(row.event_type);
    metrics[key] = (metrics[key] ?? 0) + Number(row.amount ?? 1);
    if (key === 'currencyConverterUsed' || key === 'timezoneConverterUsed') {
      metrics.converterUsed = (metrics.converterUsed ?? 0) + Number(row.amount ?? 1);
    }
    return metrics;
  }, {});
}

function trackedMetricKey(eventType) {
  switch (normalizeConditionType(eventType)) {
    case 'scanner_used':
    case 'scan_count':
      return 'scannerUsed';
    case 'ocr_used':
      return 'ocrUsed';
    case 'currency_converter_used':
      return 'currencyConverterUsed';
    case 'timezone_converter_used':
      return 'timezoneConverterUsed';
    case 'converter_used':
      return 'converterUsed';
    case 'ai_plan_used':
    case 'ai_plan_created':
    case 'ai_daily_plan_used':
      return 'aiPlanUsed';
    default:
      return normalizeConditionType(eventType).replace(/_([a-z])/g, (_, char) => char.toUpperCase());
  }
}

function hourInJakarta(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 12;
  return Number(new Intl.DateTimeFormat('en-US', {
    timeZone: 'Asia/Jakarta',
    hour: '2-digit',
    hour12: false,
  }).format(date));
}
