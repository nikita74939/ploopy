import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const select = 'id, user_id, dark_mode, language, notif_enabled, app_lock_enabled';

export async function getSettings(userId) {
  const { data, error } = await supabaseAdmin.from('app_settings').select(select).eq('user_id', userId).maybeSingle();
  if (error) throw httpError(500, error.message);
  if (data) return data;
  const created = await supabaseAdmin.from('app_settings').insert({ user_id: userId }).select(select).single();
  if (created.error) throw httpError(500, created.error.message);
  return created.data;
}

export async function updateSettings({ userId, input }) {
  await getSettings(userId);
  const payload = {};
  if (Object.hasOwn(input, 'darkMode') || Object.hasOwn(input, 'dark_mode')) payload.dark_mode = input.darkMode ?? input.dark_mode;
  if (Object.hasOwn(input, 'language')) payload.language = input.language;
  if (Object.hasOwn(input, 'notifEnabled') || Object.hasOwn(input, 'notif_enabled')) payload.notif_enabled = input.notifEnabled ?? input.notif_enabled;
  if (Object.hasOwn(input, 'appLockEnabled') || Object.hasOwn(input, 'app_lock_enabled')) payload.app_lock_enabled = input.appLockEnabled ?? input.app_lock_enabled;

  const { data, error } = await supabaseAdmin.from('app_settings').update(payload).eq('user_id', userId).select(select).single();
  if (error) throw httpError(500, error.message);
  return data;
}
