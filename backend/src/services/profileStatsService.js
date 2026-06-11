import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { getStreak } from './streakService.js';

export async function getProfileStats(userId) {
  const [friendships, activities, streak] = await Promise.all([
    supabaseAdmin
      .from('friendships')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'accepted')
      .or(`requester_id.eq.${userId},addressee_id.eq.${userId}`),
    supabaseAdmin
      .from('activities')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId),
    getStreak(userId),
  ]);

  if (friendships.error) throw httpError(500, friendships.error.message);
  if (activities.error) throw httpError(500, activities.error.message);

  return {
    friendCount: friendships.count ?? 0,
    activityCount: activities.count ?? 0,
    currentStreak: Number(streak?.current_streak ?? 0),
    longestStreak: Number(streak?.longest_streak ?? 0),
  };
}
