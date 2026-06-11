import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import { generateDailyPlan } from '../services/groqAiService.js';

export const aiRoutes = Router();

aiRoutes.use(requireAuth);

aiRoutes.post('/daily-plan', async (req, res, next) => {
  try {
    const plan = await generateDailyPlan({
      ...req.body,
      user_id: req.authUser.id,
    });
    return res.json({ plan });
  } catch (error) {
    return next(error);
  }
});
