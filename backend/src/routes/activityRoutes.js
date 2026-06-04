import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { addComment, createActivity, deleteActivity, deleteComment, getActivitiesByUser, getComments, getFeed, toggleLike, uploadActivityImage } from '../services/activityService.js';

export const activityRoutes = Router();
activityRoutes.use(requireAuth);

activityRoutes.get('/', async (req, res, next) => {
  try { return res.json({ activities: await getFeed({ userId: req.authUser.id, mine: req.query.mine === 'true' }) }); }
  catch (err) { return next(err); }
});
activityRoutes.get('/users/:userId', async (req, res, next) => {
  try { return res.json({ activities: await getActivitiesByUser({ userId: req.params.userId, currentUserId: req.authUser.id }) }); }
  catch (err) { return next(err); }
});
activityRoutes.post('/uploads', async (req, res, next) => {
  try { return res.status(201).json({ imageUrl: await uploadActivityImage({ userId: req.authUser.id, input: req.body }) }); }
  catch (err) { return next(err); }
});
activityRoutes.post('/', async (req, res, next) => {
  try { return res.status(201).json({ activity: await createActivity({ userId: req.authUser.id, input: req.body }) }); }
  catch (err) { return next(err); }
});
activityRoutes.delete('/:id', async (req, res, next) => {
  try { await deleteActivity({ userId: req.authUser.id, activityId: req.params.id }); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
activityRoutes.post('/:id/like', async (req, res, next) => {
  try { return res.json(await toggleLike({ userId: req.authUser.id, activityId: req.params.id })); }
  catch (err) { return next(err); }
});
activityRoutes.post('/:id/comments', async (req, res, next) => {
  try { return res.status(201).json({ comment: await addComment({ userId: req.authUser.id, activityId: req.params.id, content: req.body.content }) }); }
  catch (err) { return next(err); }
});
activityRoutes.get('/:id/comments', async (req, res, next) => {
  try { return res.json({ comments: await getComments({ activityId: req.params.id }) }); }
  catch (err) { return next(err); }
});
activityRoutes.delete('/comments/:id', async (req, res, next) => {
  try { await deleteComment({ userId: req.authUser.id, commentId: req.params.id }); return res.json({ success: true }); }
  catch (err) { return next(err); }
});
