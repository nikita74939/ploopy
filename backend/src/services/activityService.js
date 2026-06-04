import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const activitySelect = `
  id, user_id, text, location, achievement_id, created_at,
  users(id, name, avatar_url),
  achievements(id, name, badge_icon),
  activity_images(id, image_url, order_index),
  activity_likes(id, user_id),
  activity_comments(id, user_id, content, created_at, users(id, name, avatar_url))
`;

export async function getFeed({ userId, mine = false }) {
  let query = supabaseAdmin.from('activities').select(activitySelect).order('created_at', { ascending: false }).limit(50);
  if (mine) query = query.eq('user_id', userId);
  const { data, error } = await query;
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function createActivity({ userId, input }) {
  if (!input.text || !String(input.text).trim()) throw httpError(400, 'Isi aktivitas wajib diisi.');
  const { data, error } = await supabaseAdmin.from('activities').insert({
    user_id: userId,
    text: String(input.text).trim(),
    location: input.location ?? null,
    achievement_id: input.achievementId ?? input.achievement_id ?? null,
  }).select('id, user_id, text, location, achievement_id, created_at').single();
  if (error) throw httpError(500, error.message);

  const images = input.images ?? [];
  if (Array.isArray(images) && images.length) {
    const rows = images.map((url, index) => ({ activity_id: data.id, image_url: url, order_index: index }));
    const img = await supabaseAdmin.from('activity_images').insert(rows);
    if (img.error) throw httpError(500, img.error.message);
  }
  return data;
}

export async function deleteActivity({ userId, activityId }) {
  const owned = await supabaseAdmin.from('activities').select('id').eq('id', activityId).eq('user_id', userId).maybeSingle();
  if (owned.error) throw httpError(500, owned.error.message);
  if (!owned.data) throw httpError(404, 'Aktivitas tidak ditemukan.');
  const { error } = await supabaseAdmin.from('activities').delete().eq('id', activityId).eq('user_id', userId);
  if (error) throw httpError(500, error.message);
}

export async function toggleLike({ userId, activityId }) {
  const existing = await supabaseAdmin.from('activity_likes').select('id').eq('activity_id', activityId).eq('user_id', userId).maybeSingle();
  if (existing.error) throw httpError(500, existing.error.message);
  if (existing.data) {
    const { error } = await supabaseAdmin.from('activity_likes').delete().eq('id', existing.data.id);
    if (error) throw httpError(500, error.message);
    return { liked: false };
  }
  const { error } = await supabaseAdmin.from('activity_likes').insert({ activity_id: activityId, user_id: userId });
  if (error) throw httpError(500, error.message);
  return { liked: true };
}

export async function addComment({ userId, activityId, content }) {
  if (!content || !String(content).trim()) throw httpError(400, 'Komentar wajib diisi.');
  const { data, error } = await supabaseAdmin.from('activity_comments').insert({ activity_id: activityId, user_id: userId, content: String(content).trim() }).select('id, activity_id, user_id, content, created_at').single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function deleteComment({ userId, commentId }) {
  const { error } = await supabaseAdmin.from('activity_comments').delete().eq('id', commentId).eq('user_id', userId);
  if (error) throw httpError(500, error.message);
}
