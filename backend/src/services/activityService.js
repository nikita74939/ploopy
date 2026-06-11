import { randomUUID } from 'crypto';

import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { unlockEligibleAchievements } from './achievementService.js';
import { createNotification } from './notificationService.js';

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
  return normalizeActivities(data ?? [], userId);
}

export async function getComments({ activityId }) {
  const { data, error } = await supabaseAdmin
    .from('activity_comments')
    .select('id, activity_id, user_id, content, created_at, users(id, name, avatar_url)')
    .eq('activity_id', activityId)
    .order('created_at', { ascending: true });
  if (error) throw httpError(500, error.message);
  return normalizeActivities(data ?? [], null);
}

export async function getActivitiesByUser({ userId, currentUserId }) {
  const { data, error } = await supabaseAdmin
    .from('activities')
    .select(activitySelect)
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(50);
  if (error) throw httpError(500, error.message);
  return normalizeActivities(data ?? [], currentUserId);
}

export async function uploadActivityImage({ userId, input }) {
  const raw = input.base64 ?? input.data;
  if (!raw) throw httpError(400, 'Gambar wajib diisi.');
  const contentType = input.contentType ?? input.content_type ?? 'image/jpeg';
  const ext = contentType.includes('png') ? 'png' : contentType.includes('webp') ? 'webp' : 'jpg';
  const buffer = Buffer.from(String(raw).replace(/^data:image\/\w+;base64,/, ''), 'base64');
  if (buffer.length > 5 * 1024 * 1024) throw httpError(400, 'Ukuran gambar maksimal 5MB.');

  const path = `${userId}/${Date.now()}-${randomUUID()}.${ext}`;
  let { error } = await supabaseAdmin.storage
    .from('activity-images')
    .upload(path, buffer, { contentType, upsert: false });
  if (error && /bucket/i.test(error.message)) {
    await supabaseAdmin.storage.createBucket('activity-images', { public: true });
    const retry = await supabaseAdmin.storage
      .from('activity-images')
      .upload(path, buffer, { contentType, upsert: false });
    error = retry.error;
  }
  if (error) throw httpError(500, error.message);
  const { data } = supabaseAdmin.storage.from('activity-images').getPublicUrl(path);
  return data.publicUrl;
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
  await createNotification({
    userId,
    input: {
      title: 'Activity berhasil dibuat',
      description: 'Postingan aktivitasmu sudah tampil di feed.',
      tag: 'activity_created',
      refId: data.id,
      refType: 'activity',
    },
  });

  await unlockActivityAchievements(userId);

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
  const owner = await supabaseAdmin.from('activities').select('user_id').eq('id', activityId).maybeSingle();
  if (!owner.error && owner.data?.user_id && owner.data.user_id !== userId) {
    await createNotification({
      userId: owner.data.user_id,
      input: {
        title: 'Activity kamu disukai',
        description: 'Ada like baru di postingan aktivitasmu.',
        tag: 'activity_like',
        refId: activityId,
        refType: 'activity',
      },
    });
  }
  return { liked: true };
}

export async function addComment({ userId, activityId, content }) {
  if (!content || !String(content).trim()) throw httpError(400, 'Komentar wajib diisi.');
  const { data, error } = await supabaseAdmin.from('activity_comments').insert({ activity_id: activityId, user_id: userId, content: String(content).trim() }).select('id, activity_id, user_id, content, created_at, users(id, name, avatar_url)').single();
  if (error) throw httpError(500, error.message);
  const owner = await supabaseAdmin.from('activities').select('user_id').eq('id', activityId).maybeSingle();
  if (!owner.error && owner.data?.user_id && owner.data.user_id !== userId) {
    await createNotification({
      userId: owner.data.user_id,
      input: {
        title: 'Komentar baru',
        description: 'Ada komentar baru di postingan aktivitasmu.',
        tag: 'activity_comment',
        refId: activityId,
        refType: 'activity',
      },
    });
  }
  return data;
}

export async function deleteComment({ userId, commentId }) {
  const { error } = await supabaseAdmin.from('activity_comments').delete().eq('id', commentId).eq('user_id', userId);
  if (error) throw httpError(500, error.message);
}

function normalizeActivities(rows, currentUserId) {
  return rows.map((row) => ({
    ...row,
    like_count: row.activity_likes?.length ?? 0,
    comment_count: row.activity_comments?.length ?? 0,
    is_liked_by_me: currentUserId
      ? (row.activity_likes ?? []).some((like) => like.user_id === currentUserId)
      : false,
  }));
}

async function unlockActivityAchievements(userId) {
  try {
    const activityCount = await getActivityCount(userId);
    await unlockEligibleAchievements({
      userId,
      metrics: {
        activityCount,
        postCount: activityCount,
      },
    });
  } catch (err) {
    console.error('Failed to unlock activity achievements:', err);
  }
}

async function getActivityCount(userId) {
  const { count, error } = await supabaseAdmin
    .from('activities')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId);

  if (error) throw httpError(500, error.message);
  return count ?? 0;
}
