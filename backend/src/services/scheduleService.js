import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';

const scheduleSelect =
  'id, user_id, name, start_time, end_time, description, link, color, icon_name, repeat_type, repeat_until, created_at';

function has(input, key) {
  return Object.prototype.hasOwnProperty.call(input, key);
}

function toSchedulePayload(input, userId, { partial = false } = {}) {
  const payload = { user_id: userId };

  if (!partial || has(input, 'name')) payload.name = input.name;
  if (!partial || has(input, 'startTime') || has(input, 'start_time')) {
    payload.start_time = input.startTime ?? input.start_time;
  }
  if (!partial || has(input, 'endTime') || has(input, 'end_time')) {
    payload.end_time = input.endTime ?? input.end_time;
  }
  if (!partial || has(input, 'description')) {
    payload.description = input.description ?? null;
  }
  if (!partial || has(input, 'link') || has(input, 'url')) {
    payload.link = input.link ?? input.url ?? null;
  }
  if (!partial || has(input, 'color')) payload.color = input.color ?? 0xffff7600;
  if (!partial || has(input, 'iconName') || has(input, 'icon_name') || has(input, 'icon')) {
    payload.icon_name = input.iconName ?? input.icon_name ?? input.icon ?? 'event';
  }
  if (!partial || has(input, 'repeatType') || has(input, 'repeat_type') || has(input, 'recurrence')) {
    payload.repeat_type = input.repeatType ?? input.repeat_type ?? input.recurrence ?? 'None';
  }
  if (!partial || has(input, 'repeatUntil') || has(input, 'repeat_until') || has(input, 'recurrenceEnd')) {
    payload.repeat_until = input.repeatUntil ?? input.repeat_until ?? input.recurrenceEnd ?? null;
  }
  if (!partial || has(input, 'createdAt') || has(input, 'created_at')) {
    payload.created_at = input.createdAt ?? input.created_at ?? new Date().toISOString();
  }

  return payload;
}

function assertScheduleInput(input, { partial = false } = {}) {
  if (!partial && (!input.name || typeof input.name !== 'string')) {
    throw httpError(400, 'Nama jadwal wajib diisi.');
  }

  const startTime = input.startTime ?? input.start_time;
  const endTime = input.endTime ?? input.end_time;

  if (!partial && (!startTime || !endTime)) {
    throw httpError(400, 'Waktu mulai dan selesai wajib diisi.');
  }

  if (startTime != null && Number.isNaN(Date.parse(startTime))) {
    throw httpError(400, 'Waktu mulai tidak valid.');
  }

  if (endTime != null && Number.isNaN(Date.parse(endTime))) {
    throw httpError(400, 'Waktu selesai tidak valid.');
  }

  if (startTime != null && endTime != null && Date.parse(endTime) <= Date.parse(startTime)) {
    throw httpError(400, 'Waktu selesai harus setelah waktu mulai.');
  }

  const createdAt = input.createdAt ?? input.created_at;
  if (createdAt != null && Number.isNaN(Date.parse(createdAt))) {
    throw httpError(400, 'Waktu pembuatan jadwal tidak valid.');
  }
}

export async function getSchedules({ userId, date, upcoming }) {
  let query = supabaseAdmin
    .from('schedules')
    .select(scheduleSelect)
    .eq('user_id', userId)
    .order('start_time', { ascending: true });

  if (date) {
    const start = new Date(date);
    if (Number.isNaN(start.getTime())) {
      throw httpError(400, 'Tanggal tidak valid.');
    }
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);
    query = query.gte('start_time', start.toISOString()).lt('start_time', end.toISOString());
  }

  if (upcoming === true) {
    query = query.gte('end_time', new Date().toISOString());
  }

  const { data, error } = await query;
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function getScheduleById({ userId, scheduleId }) {
  const { data, error } = await supabaseAdmin
    .from('schedules')
    .select(scheduleSelect)
    .eq('id', scheduleId)
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw httpError(500, error.message);
  if (!data) throw httpError(404, 'Jadwal tidak ditemukan.');
  return data;
}

export async function createSchedule({ userId, input }) {
  assertScheduleInput(input);

  const { data, error } = await supabaseAdmin
    .from('schedules')
    .insert(toSchedulePayload(input, userId))
    .select(scheduleSelect)
    .single();

  if (error) throw httpError(500, error.message);
  return data;
}

export async function updateSchedule({ userId, scheduleId, input }) {
  assertScheduleInput(input, { partial: true });
  await getScheduleById({ userId, scheduleId });

  const payload = toSchedulePayload(input, userId, { partial: true });
  delete payload.user_id;
  Object.keys(payload).forEach((key) => payload[key] === undefined && delete payload[key]);

  const { data, error } = await supabaseAdmin
    .from('schedules')
    .update(payload)
    .eq('id', scheduleId)
    .eq('user_id', userId)
    .select(scheduleSelect)
    .single();

  if (error) throw httpError(500, error.message);
  return data;
}

export async function deleteSchedule({ userId, scheduleId }) {
  await getScheduleById({ userId, scheduleId });

  const { error } = await supabaseAdmin
    .from('schedules')
    .delete()
    .eq('id', scheduleId)
    .eq('user_id', userId);

  if (error) throw httpError(500, error.message);
}
