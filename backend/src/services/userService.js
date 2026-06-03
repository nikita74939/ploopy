import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

export async function getUserProfile(userId) {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('id, name, email, bio, avatar_url, joined_at, biometric_enabled')
    .eq('id', userId)
    .maybeSingle();

  if (error) {
    throw httpError(500, error.message);
  }

  if (!data) {
    throw httpError(404, 'Data user tidak ditemukan.');
  }

  return data;
}

export async function getUserByEmailWithPassword(email) {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select()
    .eq('email', email)
    .maybeSingle();

  if (error) {
    throw httpError(500, error.message);
  }

  return data;
}

export async function createUserProfile({ id, email, name, passwordHash }) {
  const { data, error } = await supabaseAdmin
    .from('users')
    .insert({
      id,
      email,
      name,
      password_hash: passwordHash,
      joined_at: new Date().toISOString(),
      biometric_enabled: false,
    })
    .select('id, name, email, bio, avatar_url, joined_at, biometric_enabled')
    .single();

  if (error) {
    throw httpError(500, error.message);
  }

  return data;
}

export async function updateBiometricEnabled({ userId, enabled }) {
  const { data, error } = await supabaseAdmin
    .from('users')
    .update({ biometric_enabled: enabled })
    .eq('id', userId)
    .select('id, name, email, bio, avatar_url, joined_at, biometric_enabled')
    .single();

  if (error) {
    throw httpError(500, error.message);
  }

  return data;
}
