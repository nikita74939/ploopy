import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import {
  endStudySession,
  getStudyMinutesByMonth,
  getStudySessions,
  getTodayStudyMinutes,
  startStudySession,
} from '../services/studyService.js';

export const studyRoutes = Router();

studyRoutes.use(requireAuth);

studyRoutes.get('/sessions', async (req, res, next) => {
  try {
    const sessions = await getStudySessions({
      userId: req.authUser.id,
      date: req.query.date,
    });
    return res.json({ sessions });
  } catch (err) {
    return next(err);
  }
});

studyRoutes.post('/sessions', async (req, res, next) => {
  try {
    const session = await startStudySession({ userId: req.authUser.id });
    return res.status(201).json({ session });
  } catch (err) {
    return next(err);
  }
});

studyRoutes.patch('/sessions/:id/end', async (req, res, next) => {
  try {
    const session = await endStudySession({
      userId: req.authUser.id,
      sessionId: req.params.id,
      durationMinutes: req.body.durationMinutes,
    });
    return res.json({ session });
  } catch (err) {
    return next(err);
  }
});

studyRoutes.get('/today', async (req, res, next) => {
  try {
    const minutes = await getTodayStudyMinutes(req.authUser.id);
    return res.json({ minutes });
  } catch (err) {
    return next(err);
  }
});

studyRoutes.get('/month', async (req, res, next) => {
  try {
    const days = await getStudyMinutesByMonth({
      userId: req.authUser.id,
      year: req.query.year,
      month: req.query.month,
    });
    return res.json({ days });
  } catch (err) {
    return next(err);
  }
});
