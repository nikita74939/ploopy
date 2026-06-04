import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { createEvent, deleteEvent, getEventById, getEventsForUser, joinEvent, leaveEvent, updateEvent } from '../services/eventService.js';

export const eventRoutes = Router();
eventRoutes.use(requireAuth);

eventRoutes.get('/', async (req, res, next) => {
  try { return res.json({ events: await getEventsForUser({ userId: req.authUser.id, upcoming: req.query.upcoming === 'true', q: req.query.q }) }); }
  catch (err) { return next(err); }
});
eventRoutes.get('/:id', async (req, res, next) => {
  try { return res.json({ event: await getEventById(req.params.id, req.authUser.id) }); }
  catch (err) { return next(err); }
});
eventRoutes.post('/', async (req, res, next) => {
  try { return res.status(201).json({ event: await createEvent({ userId: req.authUser.id, input: req.body }) }); }
  catch (err) { return next(err); }
});
eventRoutes.patch('/:id', async (req, res, next) => {
  try { return res.json({ event: await updateEvent({ userId: req.authUser.id, eventId: req.params.id, input: req.body }) }); }
  catch (err) { return next(err); }
});
eventRoutes.delete('/:id', async (req, res, next) => {
  try { await deleteEvent({ userId: req.authUser.id, eventId: req.params.id }); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
eventRoutes.post('/:id/join', async (req, res, next) => {
  try { return res.status(201).json({ participant: await joinEvent({ userId: req.authUser.id, eventId: req.params.id }) }); }
  catch (err) { return next(err); }
});
eventRoutes.delete('/:id/join', async (req, res, next) => {
  try { await leaveEvent({ userId: req.authUser.id, eventId: req.params.id }); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
