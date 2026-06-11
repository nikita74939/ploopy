import { supabaseAdmin } from '../config/supabase.js';
import { httpError } from '../utils/httpError.js';
import { createActivity } from './activityService.js';
import { evaluateUserAchievements } from './achievementService.js';
import { createNotification } from './notificationService.js';
import { checkInStreak } from './streakService.js';

const taskSelect =
  'id, user_id, name, subject, deadline, details, color, icon_name, is_pinned, is_completed, created_at';

function has(input, key) {
  return Object.prototype.hasOwnProperty.call(input, key);
}

function toTaskPayload(input, userId, { partial = false } = {}) {
  const payload = { user_id: userId };

  if (!partial || has(input, 'name')) payload.name = input.name;
  if (!partial || has(input, 'subject')) payload.subject = input.subject ?? null;
  if (!partial || has(input, 'deadline')) payload.deadline = input.deadline;
  if (!partial || has(input, 'details')) payload.details = input.details ?? null;
  if (!partial || has(input, 'color')) payload.color = input.color ?? 0xffff7600;
  if (!partial || has(input, 'iconName') || has(input, 'icon_name')) {
    payload.icon_name = input.iconName ?? input.icon_name ?? 'task';
  }
  if (!partial || has(input, 'isPinned') || has(input, 'is_pinned')) {
    payload.is_pinned = input.isPinned ?? input.is_pinned ?? false;
  }
  if (!partial || has(input, 'isCompleted') || has(input, 'is_completed')) {
    payload.is_completed = input.isCompleted ?? input.is_completed ?? false;
  }
  if (!partial || has(input, 'createdAt') || has(input, 'created_at')) {
    payload.created_at = input.createdAt ?? input.created_at ?? new Date().toISOString();
  }

  return payload;
}

function assertTaskInput(input, { partial = false } = {}) {
  if (!partial && (!input.name || typeof input.name !== 'string')) {
    throw httpError(400, 'Nama task wajib diisi.');
  }

  if (!partial && !input.deadline) {
    throw httpError(400, 'Deadline task wajib diisi.');
  }

  if (input.name != null && typeof input.name !== 'string') {
    throw httpError(400, 'Nama task harus berupa teks.');
  }

  if (input.deadline != null && Number.isNaN(Date.parse(input.deadline))) {
    throw httpError(400, 'Deadline task tidak valid.');
  }

  const createdAt = input.createdAt ?? input.created_at;
  if (createdAt != null && Number.isNaN(Date.parse(createdAt))) {
    throw httpError(400, 'Waktu pembuatan task tidak valid.');
  }
}

export async function getTasks({ userId, date, pinned }) {
  let query = supabaseAdmin
    .from('tasks')
    .select(taskSelect)
    .eq('user_id', userId)
    .order('is_pinned', { ascending: false })
    .order('deadline', { ascending: true });

  if (date) {
    const start = new Date(date);
    if (Number.isNaN(start.getTime())) {
      throw httpError(400, 'Tanggal tidak valid.');
    }
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);
    query = query.gte('deadline', start.toISOString()).lt('deadline', end.toISOString());
  }

  if (pinned === true) {
    query = query.eq('is_pinned', true);
  }

  const { data, error } = await query;
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function getTaskById({ userId, taskId }) {
  const { data, error } = await supabaseAdmin
    .from('tasks')
    .select(taskSelect)
    .eq('id', taskId)
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw httpError(500, error.message);
  if (!data) throw httpError(404, 'Task tidak ditemukan.');
  return data;
}

export async function createTask({ userId, input }) {
  assertTaskInput(input);

  const { data, error } = await supabaseAdmin
    .from('tasks')
    .insert(toTaskPayload(input, userId))
    .select(taskSelect)
    .single();

  if (error) throw httpError(500, error.message);
  await notifyTaskDeadline(userId, data);
  await evaluateUserAchievements({ userId, triggerType: 'task_created' });
  return data;
}

export async function updateTask({ userId, taskId, input }) {
  assertTaskInput(input, { partial: true });
  const previousTask = await getTaskById({ userId, taskId });

  const payload = toTaskPayload(input, userId, { partial: true });
  delete payload.user_id;
  Object.keys(payload).forEach((key) => payload[key] === undefined && delete payload[key]);

  const { data, error } = await supabaseAdmin
    .from('tasks')
    .update(payload)
    .eq('id', taskId)
    .eq('user_id', userId)
    .select(taskSelect)
    .single();

  if (error) throw httpError(500, error.message);
  await recordTaskCompletionIfNeeded(userId, previousTask, data);
  await notifyTaskDeadline(userId, data);
  return data;
}

export async function deleteTask({ userId, taskId }) {
  await getTaskById({ userId, taskId });

  const { error } = await supabaseAdmin
    .from('tasks')
    .delete()
    .eq('id', taskId)
    .eq('user_id', userId);

  if (error) throw httpError(500, error.message);
}

export async function setTaskCompletion({ userId, taskId, completed }) {
  if (typeof completed !== 'boolean') {
    throw httpError(400, 'Field completed harus boolean.');
  }

  const previousTask = await getTaskById({ userId, taskId });

  const { data, error } = await supabaseAdmin
    .from('tasks')
    .update({ is_completed: completed })
    .eq('id', taskId)
    .eq('user_id', userId)
    .select(taskSelect)
    .single();

  if (error) throw httpError(500, error.message);
  await recordTaskCompletionIfNeeded(userId, previousTask, data);
  return data;
}

export async function setTaskPin({ userId, taskId, pinned }) {
  if (typeof pinned !== 'boolean') {
    throw httpError(400, 'Field pinned harus boolean.');
  }

  await getTaskById({ userId, taskId });

  const { data, error } = await supabaseAdmin
    .from('tasks')
    .update({ is_pinned: pinned })
    .eq('id', taskId)
    .eq('user_id', userId)
    .select(taskSelect)
    .single();

  if (error) throw httpError(500, error.message);
  return data;
}

async function notifyTaskDeadline(userId, task) {
  if (!task.deadline || task.is_completed) return;
  const deadline = new Date(task.deadline);
  if (Number.isNaN(deadline.getTime())) return;
  const days = Math.ceil((deadline.getTime() - Date.now()) / 86400000);
  if (days > 3) return;

  const detail = days < 0
    ? `Deadline "${task.name}" sudah lewat.`
    : days === 0
      ? `Deadline "${task.name}" hari ini.`
      : `Deadline "${task.name}" dalam ${days} hari.`;
  await createNotification({
    userId,
    input: {
      title: 'Deadline task',
      description: detail,
      tag: 'task_deadline',
      refId: task.id,
      refType: 'task',
    },
  });
}

async function recordTaskCompletionIfNeeded(userId, previousTask, task) {
  if (!task.is_completed || previousTask.is_completed) return;

  await Promise.all([
    checkInStreak(userId),
    evaluateUserAchievements({ userId, triggerType: 'task_completed' }),
    createNotification({
      userId,
      input: {
        title: 'Task selesai',
        description: `Kamu menyelesaikan "${task.name}".`,
        tag: 'task_completed',
        refId: task.id,
        refType: 'task',
      },
    }),
    createActivity({
      userId,
      input: {
        text: `Menyelesaikan tugas "${task.name}".`,
      },
    }),
  ]);
}
