import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import {
  getAllAchievements,
  getAchievementStatus,
  getUserAchievements,
  trackAchievementEvent,
  unlockUserAchievement,
} from '../services/achievementService.js';
import { httpError } from '../utils/httpError.js';

export const achievementRoutes = Router();

achievementRoutes.get('/', requireAuth, async (req, res, next) => {
  try {
    const achievements = await getAllAchievements();
    return res.json({ achievements });
  } catch (err) {
    return next(err);
  }
});

achievementRoutes.get('/status', requireAuth, async (req, res, next) => {
  try {
    const achievements = await getAchievementStatus(req.authUser.id);
    return res.json({ achievements });
  } catch (err) {
    return next(err);
  }
});

achievementRoutes.post('/track', requireAuth, async (req, res, next) => {
  try {
    const result = await trackAchievementEvent({
      userId: req.authUser.id,
      eventType: req.body.eventType ?? req.body.event_type,
      amount: req.body.amount,
    });
    return res.status(201).json(result);
  } catch (err) {
    return next(err);
  }
});

achievementRoutes.get('/users/:userId', requireAuth, async (req, res, next) => {
  try {
    const { userId } = req.params;

    if (req.authUser.id !== userId) {
      throw httpError(403, 'Tidak boleh melihat achievement user lain.');
    }

    const userAchievements = await getUserAchievements(userId);
    return res.json({ userAchievements });
  } catch (err) {
    return next(err);
  }
});

achievementRoutes.post('/users/:userId', requireAuth, async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { achievementId } = req.body;

    if (req.authUser.id !== userId) {
      throw httpError(403, 'Tidak boleh mengubah achievement user lain.');
    }

    if (!achievementId || typeof achievementId !== 'string') {
      throw httpError(400, 'Field achievementId wajib diisi.');
    }

    const userAchievement = await unlockUserAchievement({
      userId,
      achievementId,
    });

    return res.status(201).json({ userAchievement });
  } catch (err) {
    return next(err);
  }
});
