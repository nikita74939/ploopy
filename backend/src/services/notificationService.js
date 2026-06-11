import { supabaseAdmin } from "../config/supabase.js";
import { httpError } from "../utils/httpError.js";

const select =
  "id, user_id, sender_user_id, title, description, tag, is_read, created_at, ref_id, ref_type";
const fallbackSelect =
  "id, user_id, title, description, tag, is_read, created_at, ref_id, ref_type";

export async function getNotifications({ userId, unreadOnly = false }) {
  let query = supabaseAdmin
    .from("notifications")
    .select(select)
    .eq("user_id", userId)
    .order("created_at", { ascending: false });
  if (unreadOnly) query = query.eq("is_read", false);
  const { data, error } = await query.limit(100);
  if (isMissingSenderUserIdColumn(error)) {
    let fallbackQuery = supabaseAdmin
      .from("notifications")
      .select(fallbackSelect)
      .eq("user_id", userId)
      .order("created_at", { ascending: false });
    if (unreadOnly) fallbackQuery = fallbackQuery.eq("is_read", false);
    const fallback = await fallbackQuery.limit(100);
    if (fallback.error) throw httpError(500, fallback.error.message);
    return fallback.data ?? [];
  }
  if (error) throw httpError(500, error.message);
  return data ?? [];
}

export async function getUnreadNotificationCount(userId) {
  const { count, error } = await supabaseAdmin
    .from("notifications")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("is_read", false);
  if (error) throw httpError(500, error.message);
  return count ?? 0;
}

export async function createNotification({
  userId,
  recipientUserId,
  senderUserId = null,
  input = {},
}) {
  const recipient = recipientUserId ?? userId;
  if (!recipient) throw httpError(400, "Penerima notifikasi wajib diisi.");
  if (!input.title) throw httpError(400, "Title notifikasi wajib diisi.");

  const payload = {
    user_id: recipient,
    title: input.title,
    description: input.description ?? input.message ?? input.body ?? null,
    tag: input.tag ?? input.type ?? "general",
    sender_user_id: normalizeUuid(
      senderUserId ?? input.senderUserId ?? input.sender_user_id,
    ),
    ref_id: normalizeUuid(input.refId ?? input.ref_id),
    ref_type: input.refType ?? input.ref_type ?? null,
  };

  const { data, error } = await supabaseAdmin
    .from("notifications")
    .insert(payload)
    .select(select)
    .single();
  if (isMissingSenderUserIdColumn(error)) {
    const { sender_user_id, ...fallbackPayload } = payload;
    const fallback = await supabaseAdmin
      .from("notifications")
      .insert(fallbackPayload)
      .select(fallbackSelect)
      .single();
    if (fallback.error) throw httpError(500, fallback.error.message);
    return fallback.data;
  }
  if (error) throw httpError(500, error.message);
  return data;
}

export async function createSelfNotification({ userId, input }) {
  return createNotification({ userId, recipientUserId: userId, input });
}

function normalizeUuid(value) {
  if (value == null) return null;
  const raw = String(value).trim();
  if (!raw) return null;
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    raw,
  )
    ? raw
    : null;
}

export async function markNotificationRead({
  userId,
  notificationId,
  read = true,
}) {
  const { data, error } = await supabaseAdmin
    .from("notifications")
    .update({ is_read: read })
    .eq("id", notificationId)
    .eq("user_id", userId)
    .select(select)
    .single();
  if (isMissingSenderUserIdColumn(error)) {
    const fallback = await supabaseAdmin
      .from("notifications")
      .update({ is_read: read })
      .eq("id", notificationId)
      .eq("user_id", userId)
      .select(fallbackSelect)
      .single();
    if (fallback.error) throw httpError(500, fallback.error.message);
    return fallback.data;
  }
  if (error) throw httpError(500, error.message);
  return data;
}

export async function markAllNotificationsRead(userId) {
  const { error } = await supabaseAdmin
    .from("notifications")
    .update({ is_read: true })
    .eq("user_id", userId)
    .eq("is_read", false);
  if (error) throw httpError(500, error.message);
}

export async function deleteNotification({ userId, notificationId }) {
  const { error } = await supabaseAdmin
    .from("notifications")
    .delete()
    .eq("id", notificationId)
    .eq("user_id", userId);
  if (error) throw httpError(500, error.message);
}

function isMissingSenderUserIdColumn(error) {
  return Boolean(
    error &&
    (error.code === "42703" ||
      /sender_user_id|column .* does not exist/i.test(error.message ?? "")),
  );
}
