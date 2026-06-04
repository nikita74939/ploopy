import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const publicUserSelect = 'id, name, email, bio, avatar_url, joined_at, biometric_enabled';

export async function getUserProfile(userId) {
  const { data, error } = await supabaseAdmin.from('users').select(publicUserSelect).eq('id', userId).maybeSingle();
  if (error) throw httpError(500, error.message);
  if (!data) throw httpError(404, 'Data user tidak ditemukan.');
  return data;
}

export async function getPublicUsers({ q, excludeUserId }) {
  let query = supabaseAdmin.from('users').select('id, name, email, bio, avatar_url, joined_at').order('name');
  if (q) query = query.or(`name.ilike.%${q}%,email.ilike.%${q}%`);
  if (excludeUserId) query = query.neq('id', excludeUserId);
  const { data, error } = await query.limit(50);
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function getUserByEmailWithPassword(email) {
  const { data, error } = await supabaseAdmin.from('users').select().eq('email', email).maybeSingle();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function createUserProfile({ id, email, name, passwordHash }) {
  const { data, error } = await supabaseAdmin.from('users').insert({
    id,
    email,
    name,
    password_hash: passwordHash,
    joined_at: new Date().toISOString(),
    biometric_enabled: false,
  }).select(publicUserSelect).single();
  if (error) throw httpError(500, error.message);

  await Promise.allSettled([
    supabaseAdmin.from('app_settings').insert({ user_id: data.id }),
    supabaseAdmin.from('streaks').insert({ user_id: data.id }),
  ]);

  return data;
}

export async function updateUserProfile({ userId, input }) {
  const payload = {};
  if (Object.hasOwn(input, 'name')) payload.name = input.name;
  if (Object.hasOwn(input, 'bio')) payload.bio = input.bio ?? null;
  if (Object.hasOwn(input, 'avatarUrl') || Object.hasOwn(input, 'avatar_url')) payload.avatar_url = input.avatarUrl ?? input.avatar_url ?? null;
  if (payload.name != null && !String(payload.name).trim()) throw httpError(400, 'Nama wajib diisi.');

  const { data, error } = await supabaseAdmin.from('users').update(payload).eq('id', userId).select(publicUserSelect).single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function uploadUserAvatar({ userId, input }) {
  const base64 = input.base64 ?? input.imageBase64 ?? input.image_base64;
  if (!base64 || typeof base64 !== 'string') throw httpError(400, 'Foto profil wajib diisi.');

  const contentType = input.contentType ?? input.content_type ?? 'image/jpeg';
  if (!['image/jpeg', 'image/png', 'image/webp'].includes(contentType)) {
    throw httpError(400, 'Format foto profil tidak didukung.');
  }

  const extension = contentType === 'image/png' ? 'png' : contentType === 'image/webp' ? 'webp' : 'jpg';
  const bytes = Buffer.from(base64.replace(/^data:image\/\w+;base64,/, ''), 'base64');
  if (!bytes.length) throw httpError(400, 'Foto profil tidak valid.');

  const path = `${userId}/avatar_${Date.now()}.${extension}`;
  const { error } = await supabaseAdmin.storage
    .from('avatars')
    .upload(path, bytes, { contentType, upsert: true });
  if (error) throw httpError(500, error.message);

  const { data: publicUrlData } = supabaseAdmin.storage.from('avatars').getPublicUrl(path);
  return updateUserProfile({ userId, input: { avatarUrl: publicUrlData.publicUrl } });
}

export async function updateBiometricEnabled({ userId, enabled }) {
  const { data, error } = await supabaseAdmin.from('users').update({ biometric_enabled: enabled }).eq('id', userId).select(publicUserSelect).single();
  if (error) throw httpError(500, error.message);
  return data;
}
