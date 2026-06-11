import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { createNotification, deleteNotification, getNotifications, markAllNotificationsRead, markNotificationRead } from '../services/notificationService.js';

export const notificationRoutes = Router();
notificationRoutes.use(requireAuth);

notificationRoutes.get('/', async (req, res, next) => {
  try { return res.json({ notifications: await getNotifications({ userId: req.authUser.id, unreadOnly: req.query.unread === 'true' }) }); }
  catch (err) { return next(err); }
});
notificationRoutes.post('/', async (req, res, next) => {
  try { return res.status(201).json({ notification: await createNotification({ userId: req.authUser.id, input: req.body }) }); }
  catch (err) { return next(err); }
});
notificationRoutes.patch('/:id/read', async (req, res, next) => {
  try { return res.json({ notification: await markNotificationRead({ userId: req.authUser.id, notificationId: req.params.id, read: req.body.read ?? true }) }); }
  catch (err) { return next(err); }
});
notificationRoutes.patch('/read-all', async (req, res, next) => {
  try { await markAllNotificationsRead(req.authUser.id); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
notificationRoutes.delete('/:id', async (req, res, next) => {
  try { await deleteNotification({ userId: req.authUser.id, notificationId: req.params.id }); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
