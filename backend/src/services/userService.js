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

export async function updateBiometricEnabled({ userId, enabled }) {
  const { data, error } = await supabaseAdmin.from('users').update({ biometric_enabled: enabled }).eq('id', userId).select(publicUserSelect).single();
  if (error) throw httpError(500, error.message);
  return data;
}
