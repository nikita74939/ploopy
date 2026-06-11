import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { evaluateUserAchievements } from './achievementService.js';
import { createNotification } from './notificationService.js';

const eventSelect = `id, creator_id, name, icon, color, event_date, location, latitude, longitude, place_id, address, is_online, max_participants, description, created_at, price,
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
  const isOnline = input.isOnline ?? input.is_online ?? false;
  const latitude = normalizeCoordinate(input.latitude);
  const longitude = normalizeCoordinate(input.longitude);
  validateLocation({ isOnline, latitude, longitude });
  const { data, error } = await supabaseAdmin.from('events').insert({
    creator_id: userId,
    name: String(input.name).trim(),
    icon: input.icon ?? 'event',
    color: input.color ?? '#FF7600',
    event_date: input.eventDate ?? input.event_date ?? null,
    location: input.location ?? null,
    latitude,
    longitude,
    place_id: input.placeId ?? input.place_id ?? null,
    address: input.address ?? null,
    is_online: isOnline,
    max_participants: input.maxParticipants ?? input.max_participants ?? null,
    description: input.description ?? null,
    price: input.price ?? 0,
  }).select(eventSelect).single();
  if (error) throw httpError(500, error.message);
  await evaluateUserAchievements({ userId, triggerType: 'event_created' });
  return data;
}

export async function updateEvent({ userId, eventId, input }) {
  const event = await getEventById(eventId);
  if (event.creator_id !== userId) throw httpError(403, 'Tidak boleh mengubah event orang lain.');
  const payload = {};
  for (const [apiKey, dbKey] of [['name','name'],['icon','icon'],['color','color'],['location','location'],['description','description'],['price','price'],['address','address']]) {
    if (Object.hasOwn(input, apiKey)) payload[dbKey] = input[apiKey];
  }
  if (Object.hasOwn(input, 'placeId') || Object.hasOwn(input, 'place_id')) payload.place_id = input.placeId ?? input.place_id;
  if (Object.hasOwn(input, 'latitude')) payload.latitude = normalizeCoordinate(input.latitude);
  if (Object.hasOwn(input, 'longitude')) payload.longitude = normalizeCoordinate(input.longitude);
  if (Object.hasOwn(input, 'eventDate') || Object.hasOwn(input, 'event_date')) payload.event_date = input.eventDate ?? input.event_date;
  if (Object.hasOwn(input, 'isOnline') || Object.hasOwn(input, 'is_online')) payload.is_online = input.isOnline ?? input.is_online;
  if (Object.hasOwn(input, 'maxParticipants') || Object.hasOwn(input, 'max_participants')) payload.max_participants = input.maxParticipants ?? input.max_participants;
  validateLocation({
    isOnline: payload.is_online ?? event.is_online,
    latitude: Object.hasOwn(payload, 'latitude') ? payload.latitude : event.latitude,
    longitude: Object.hasOwn(payload, 'longitude') ? payload.longitude : event.longitude,
  });

  const { data, error } = await supabaseAdmin.from('events').update(payload).eq('id', eventId).select(eventSelect).single();
  if (error) throw httpError(500, error.message);
  await notifyEventParticipants({
    event: data,
    actorId: userId,
    title: 'Event diperbarui',
    description: `"${data.name}" baru saja diperbarui oleh pembuat event.`,
    tag: 'event_updated',
  });
  return data;
}

function normalizeCoordinate(value) {
  if (value == null || value === '') return null;
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function validateLocation({ isOnline, latitude, longitude }) {
  if (isOnline) return;
  if (latitude == null || longitude == null) {
    throw httpError(400, 'Event offline wajib memiliki titik lokasi di peta.');
  }
  if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    throw httpError(400, 'Koordinat lokasi event tidak valid.');
  }
}

export async function deleteEvent({ userId, eventId }) {
  const event = await getEventById(eventId);
  if (event.creator_id !== userId) throw httpError(403, 'Tidak boleh menghapus event orang lain.');
  const { error } = await supabaseAdmin.from('events').delete().eq('id', eventId);
  if (error) throw httpError(500, error.message);
  await notifyEventParticipants({
    event,
    actorId: userId,
    title: 'Event dibatalkan',
    description: `"${event.name}" sudah dihapus oleh pembuat event.`,
    tag: 'event_cancelled',
  });
}

export async function joinEvent({ userId, eventId }) {
  const event = await getEventById(eventId);
  const exists = await supabaseAdmin.from('event_participants').select('id').eq('event_id', eventId).eq('user_id', userId).maybeSingle();
  if (exists.error) throw httpError(500, exists.error.message);
  if (exists.data) return exists.data;
  if (event.max_participants && (event.event_participants?.length ?? 0) >= event.max_participants) throw httpError(400, 'Event sudah penuh.');
  const { data, error } = await supabaseAdmin.from('event_participants').insert({ event_id: eventId, user_id: userId }).select('id, event_id, user_id, joined_at').single();
  if (error) throw httpError(500, error.message);
  await evaluateUserAchievements({ userId, triggerType: 'event_joined' });
  await createNotification({
    userId,
    input: {
      title: 'Berhasil join event',
      description: `Kamu sudah bergabung ke "${event.name}".`,
      tag: 'event_joined',
      refId: eventId,
      refType: 'event',
    },
  });
  if (event.creator_id && event.creator_id !== userId) {
    await createNotification({
      userId: event.creator_id,
      senderUserId: userId,
      input: {
        title: 'Peserta event baru',
        description: `Ada peserta baru yang bergabung ke "${event.name}".`,
        tag: 'event_participant_joined',
        refId: eventId,
        refType: 'event',
      },
    });
  }
  return data;
}

export async function leaveEvent({ userId, eventId }) {
  const { error } = await supabaseAdmin.from('event_participants').delete().eq('event_id', eventId).eq('user_id', userId);
  if (error) throw httpError(500, error.message);
}

async function notifyEventParticipants({ event, actorId, title, description, tag }) {
  const participantIds = [
    ...(event.event_participants ?? []).map((participant) => participant.user_id),
    event.creator_id,
  ].filter(Boolean);
  const recipients = [...new Set(participantIds)].filter((id) => id !== actorId);

  await Promise.all(recipients.map((recipientId) => createNotification({
    userId: recipientId,
    senderUserId: actorId,
    input: {
      title,
      description,
      tag,
      refId: event.id,
      refType: 'event',
    },
  })));
}
