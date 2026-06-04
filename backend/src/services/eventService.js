import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const eventSelect = `id, creator_id, name, icon, color, event_date, location, is_online, max_participants, description, created_at, price,
  creator:users!events_creator_id_fkey(id, name, avatar_url),
  event_participants(id, user_id, joined_at, users(id, name, avatar_url))`;

export async function getEvents({ upcoming = false, q }) {
  let query = supabaseAdmin.from('events').select(eventSelect).order('event_date', { ascending: true });
  if (upcoming) query = query.gte('event_date', new Date().toISOString());
  if (q) query = query.ilike('name', `%${q}%`);
  const { data, error } = await query.limit(100);
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

function decorateEvent(event, userId) {
  const participants = event.event_participants ?? [];
  return {
    ...event,
    current_participants: participants.length,
    is_joined_by_me: Boolean(userId && participants.some((item) => item.user_id === userId)),
  };
}

export async function getEventsForUser({ userId, upcoming = false, q }) {
  const events = await getEvents({ upcoming, q });
  return events.map((event) => decorateEvent(event, userId));
}

export async function getEventById(eventId, userId = null) {
  const { data, error } = await supabaseAdmin.from('events').select(eventSelect).eq('id', eventId).maybeSingle();
  if (error) throw httpError(500, error.message);
  if (!data) throw httpError(404, 'Event tidak ditemukan.');
  return decorateEvent(data, userId);
}

export async function createEvent({ userId, input }) {
  if (!input.name || !String(input.name).trim()) throw httpError(400, 'Nama event wajib diisi.');
  if (input.eventDate && Number.isNaN(Date.parse(input.eventDate))) throw httpError(400, 'Tanggal event tidak valid.');
  const { data, error } = await supabaseAdmin.from('events').insert({
    creator_id: userId,
    name: String(input.name).trim(),
    icon: input.icon ?? 'event',
    color: input.color ?? '#FF7600',
    event_date: input.eventDate ?? input.event_date ?? null,
    location: input.location ?? null,
    is_online: input.isOnline ?? input.is_online ?? false,
    max_participants: input.maxParticipants ?? input.max_participants ?? null,
    description: input.description ?? null,
    price: input.price ?? 0,
  }).select('id, creator_id, name, icon, color, event_date, location, is_online, max_participants, description, created_at, price').single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function updateEvent({ userId, eventId, input }) {
  const event = await getEventById(eventId);
  if (event.creator_id !== userId) throw httpError(403, 'Tidak boleh mengubah event orang lain.');
  const payload = {};
  for (const [apiKey, dbKey] of [['name','name'],['icon','icon'],['color','color'],['location','location'],['description','description'],['price','price']]) {
    if (Object.hasOwn(input, apiKey)) payload[dbKey] = input[apiKey];
  }
  if (Object.hasOwn(input, 'eventDate') || Object.hasOwn(input, 'event_date')) payload.event_date = input.eventDate ?? input.event_date;
  if (Object.hasOwn(input, 'isOnline') || Object.hasOwn(input, 'is_online')) payload.is_online = input.isOnline ?? input.is_online;
  if (Object.hasOwn(input, 'maxParticipants') || Object.hasOwn(input, 'max_participants')) payload.max_participants = input.maxParticipants ?? input.max_participants;

  const { data, error } = await supabaseAdmin.from('events').update(payload).eq('id', eventId).select('id, creator_id, name, icon, color, event_date, location, is_online, max_participants, description, created_at, price').single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function deleteEvent({ userId, eventId }) {
  const event = await getEventById(eventId);
  if (event.creator_id !== userId) throw httpError(403, 'Tidak boleh menghapus event orang lain.');
  const { error } = await supabaseAdmin.from('events').delete().eq('id', eventId);
  if (error) throw httpError(500, error.message);
}

export async function joinEvent({ userId, eventId }) {
  const event = await getEventById(eventId);
  const exists = await supabaseAdmin.from('event_participants').select('id').eq('event_id', eventId).eq('user_id', userId).maybeSingle();
  if (exists.error) throw httpError(500, exists.error.message);
  if (exists.data) return exists.data;
  if (event.max_participants && (event.event_participants?.length ?? 0) >= event.max_participants) throw httpError(400, 'Event sudah penuh.');
  const { data, error } = await supabaseAdmin.from('event_participants').insert({ event_id: eventId, user_id: userId }).select('id, event_id, user_id, joined_at').single();
  if (error) throw httpError(500, error.message);
  return data;
}

export async function leaveEvent({ userId, eventId }) {
  const { error } = await supabaseAdmin.from('event_participants').delete().eq('event_id', eventId).eq('user_id', userId);
  if (error) throw httpError(500, error.message);
}
