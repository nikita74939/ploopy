import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const select = `id, requester_id, addressee_id, status, created_at,
  requester:users!friendships_requester_id_fkey(id, name, avatar_url),
  addressee:users!friendships_addressee_id_fkey(id, name, avatar_url)`;

export async function getFriendships(userId) {
  const { data, error } = await supabaseAdmin
    .from('friendships')
    .select(select)
    .or(`requester_id.eq.${userId},addressee_id.eq.${userId}`)
    .order('created_at', { ascending: false });
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function sendFriendRequest({ requesterId, addresseeId }) {
  if (!addresseeId) throw httpError(400, 'addresseeId wajib diisi.');
  if (requesterId === addresseeId) throw httpError(400, 'Tidak bisa menambahkan diri sendiri.');

  const existing = await supabaseAdmin
    .from('friendships')
    .select('id, status')
    .or(`and(requester_id.eq.${requesterId},addressee_id.eq.${addresseeId}),and(requester_id.eq.${addresseeId},addressee_id.eq.${requesterId})`)
    .maybeSingle();
  if (existing.error) throw httpError(500, existing.error.message);
  if (existing.data) return existing.data;

  const { data, error } = await supabaseAdmin.from('friendships').insert({ requester_id: requesterId, addressee_id: addresseeId, status: 'pending' }).select('id, requester_id, addressee_id, status, created_at').single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function updateFriendshipStatus({ userId, friendshipId, status }) {
  if (!['accepted', 'rejected', 'blocked'].includes(status)) throw httpError(400, 'Status tidak valid.');
  const current = await supabaseAdmin.from('friendships').select('id, requester_id, addressee_id').eq('id', friendshipId).maybeSingle();
  if (current.error) throw httpError(500, current.error.message);
  if (!current.data) throw httpError(404, 'Permintaan teman tidak ditemukan.');
  if (![current.data.requester_id, current.data.addressee_id].includes(userId)) throw httpError(403, 'Tidak boleh mengubah data ini.');

  const { data, error } = await supabaseAdmin.from('friendships').update({ status }).eq('id', friendshipId).select('id, requester_id, addressee_id, status, created_at').single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function removeFriendship({ userId, friendshipId }) {
  const current = await supabaseAdmin.from('friendships').select('id, requester_id, addressee_id').eq('id', friendshipId).maybeSingle();
  if (current.error) throw httpError(500, current.error.message);
  if (!current.data) throw httpError(404, 'Pertemanan tidak ditemukan.');
  if (![current.data.requester_id, current.data.addressee_id].includes(userId)) throw httpError(403, 'Tidak boleh menghapus data ini.');

  const { error } = await supabaseAdmin.from('friendships').delete().eq('id', friendshipId);
  if (error) throw httpError(500, error.message);
}
