import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { getProfileStats } from '../services/profileStatsService.js';

export const profileRoutes = Router();
profileRoutes.use(requireAuth);

profileRoutes.get('/stats', async (req, res, next) => {
  try {
    const stats = await getProfileStats(req.authUser.id);
    return res.json({ ...stats, stats });
  } catch (err) {
    return next(err);
  }
});
