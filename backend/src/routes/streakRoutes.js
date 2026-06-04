import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { checkInStreak, getStreak } from '../services/streakService.js';

export const streakRoutes = Router();
streakRoutes.use(requireAuth);

streakRoutes.get('/me', async (req, res, next) => {
  try { return res.json({ streak: await getStreak(req.authUser.id) }); }
  catch (err) { return next(err); }
});

streakRoutes.post('/check-in', async (req, res, next) => {
  try { return res.json({ streak: await checkInStreak(req.authUser.id) }); }
  catch (err) { return next(err); }
});
