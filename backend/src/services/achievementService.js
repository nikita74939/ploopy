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
