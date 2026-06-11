import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import {
  createSchedule,
  deleteSchedule,
  getScheduleById,
  getSchedules,
  updateSchedule,
} from '../services/scheduleService.js';

export const scheduleRoutes = Router();

scheduleRoutes.use(requireAuth);

scheduleRoutes.get('/', async (req, res, next) => {
  try {
    const schedules = await getSchedules({
      userId: req.authUser.id,
      date: req.query.date,
      upcoming: req.query.upcoming === 'true',
    });
    return res.json({ schedules });
  } catch (err) {
    return next(err);
  }
});

scheduleRoutes.get('/:id', async (req, res, next) => {
  try {
    const schedule = await getScheduleById({
      userId: req.authUser.id,
      scheduleId: req.params.id,
    });
    return res.json({ schedule });
  } catch (err) {
    return next(err);
  }
});

scheduleRoutes.post('/', async (req, res, next) => {
  try {
    const schedule = await createSchedule({
      userId: req.authUser.id,
      input: req.body,
    });
    return res.status(201).json({ schedule });
  } catch (err) {
    return next(err);
  }
});

scheduleRoutes.patch('/:id', async (req, res, next) => {
  try {
    const schedule = await updateSchedule({
      userId: req.authUser.id,
      scheduleId: req.params.id,
      input: req.body,
    });
    return res.json({ schedule });
  } catch (err) {
    return next(err);
  }
});

scheduleRoutes.delete('/:id', async (req, res, next) => {
  try {
    await deleteSchedule({
      userId: req.authUser.id,
      scheduleId: req.params.id,
    });
    return res.json({ success: true });
  } catch (err) {
    return next(err);
  }
});
