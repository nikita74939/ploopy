import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { getHomeDashboard } from '../services/dashboardService.js';

export const dashboardRoutes = Router();
dashboardRoutes.use(requireAuth);

dashboardRoutes.get('/home', async (req, res, next) => {
  try {
    const date = req.query.date ?? new Date().toISOString();
    return res.json({ dashboard: await getHomeDashboard(req.authUser.id, date) });
  } catch (err) { return next(err); }
});
