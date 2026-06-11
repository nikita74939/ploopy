import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const select = 'id, user_id, title, description, tag, is_read, created_at, ref_id, ref_type';

export async function getNotifications({ userId, unreadOnly = false }) {
  let query = supabaseAdmin.from('notifications').select(select).eq('user_id', userId).order('created_at', { ascending: false });
  if (unreadOnly) query = query.eq('is_read', false);
  const { data, error } = await query.limit(100);
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function createNotification({ userId, input }) {
  if (!input.title) throw httpError(400, 'Title notifikasi wajib diisi.');
  const { data, error } = await supabaseAdmin.from('notifications').insert({
    user_id: input.userId ?? input.user_id ?? userId,
    title: input.title,
    description: input.description ?? null,
    tag: input.tag ?? null,
    ref_id: normalizeUuid(input.refId ?? input.ref_id),
    ref_type: input.refType ?? input.ref_type ?? null,
  }).select(select).single();
  if (error) throw httpError(500, error.message);
  return data;
}

function normalizeUuid(value) {
  if (value == null) return null;
  const raw = String(value).trim();
  if (!raw) return null;
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(raw)
    ? raw
    : null;
}

export async function markNotificationRead({ userId, notificationId, read = true }) {
  const { data, error } = await supabaseAdmin.from('notifications').update({ is_read: read }).eq('id', notificationId).eq('user_id', userId).select(select).single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function markAllNotificationsRead(userId) {
  const { error } = await supabaseAdmin.from('notifications').update({ is_read: true }).eq('user_id', userId).eq('is_read', false);
  if (error) throw httpError(500, error.message);
}

export async function deleteNotification({ userId, notificationId }) {
  const { error } = await supabaseAdmin.from('notifications').delete().eq('id', notificationId).eq('user_id', userId);
  if (error) throw httpError(500, error.message);
}
