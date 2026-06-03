import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

export async function getUserProfile(userId) {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select()
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

export async function createUserProfile({ id, email, name }) {
  const { data, error } = await supabaseAdmin
    .from('users')
    .insert({
      id,
      email,
      name,
      joined_at: new Date().toISOString(),
      biometric_enabled: false,
    })
    .select()
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
    .select()
    .single();

  if (error) {
    throw httpError(500, error.message);
  }

  return data;
}
