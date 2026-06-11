import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import { generateDailyPlan } from '../services/groqAiService.js';
import { trackAchievementEvent } from '../services/achievementService.js';
import { createNotification } from '../services/notificationService.js';

export const aiRoutes = Router();

aiRoutes.use(requireAuth);

aiRoutes.post('/daily-plan', async (req, res, next) => {
  try {
    const plan = await generateDailyPlan({
      ...req.body,
      user_id: req.authUser.id,
    });
    await createNotification({
      userId: req.authUser.id,
      input: {
        title: 'AI Daily Plan siap',
        description: 'Rekomendasi jadwal harian dari AI sudah berhasil dibuat.',
        tag: 'ai_plan_created',
        refType: 'ai_daily_plan',
      },
    });
    try {
      await trackAchievementEvent({
        userId: req.authUser.id,
        eventType: 'ai_plan_used',
      });
    } catch (achievementError) {
      console.error('Failed to track AI achievement:', achievementError);
    }
    return res.json({ plan });
  } catch (error) {
    return next(error);
  }
});
