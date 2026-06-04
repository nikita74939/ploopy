import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { getFriendships, removeFriendship, sendFriendRequest, updateFriendshipStatus } from '../services/friendService.js';

export const friendRoutes = Router();
friendRoutes.use(requireAuth);

friendRoutes.get('/', async (req, res, next) => {
  try { return res.json({ friendships: await getFriendships(req.authUser.id) }); }
  catch (err) { return next(err); }
});
friendRoutes.post('/', async (req, res, next) => {
  try { return res.status(201).json({ friendship: await sendFriendRequest({ requesterId: req.authUser.id, addresseeId: req.body.addresseeId ?? req.body.addressee_id }) }); }
  catch (err) { return next(err); }
});
friendRoutes.patch('/:id', async (req, res, next) => {
  try { return res.json({ friendship: await updateFriendshipStatus({ userId: req.authUser.id, friendshipId: req.params.id, status: req.body.status }) }); }
  catch (err) { return next(err); }
});
friendRoutes.delete('/:id', async (req, res, next) => {
  try { await removeFriendship({ userId: req.authUser.id, friendshipId: req.params.id }); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
