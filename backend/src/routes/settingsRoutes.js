import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { getSettings, updateSettings } from '../services/settingsService.js';

export const settingsRoutes = Router();
settingsRoutes.use(requireAuth);

settingsRoutes.get('/me', async (req, res, next) => {
  try { return res.json({ settings: await getSettings(req.authUser.id) }); }
  catch (err) { return next(err); }
});

settingsRoutes.patch('/me', async (req, res, next) => {
  try { return res.json({ settings: await updateSettings({ userId: req.authUser.id, input: req.body }) }); }
  catch (err) { return next(err); }
});
