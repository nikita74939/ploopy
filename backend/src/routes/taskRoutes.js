import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import {
  createTask,
  deleteTask,
  getTaskById,
  getTasks,
  setTaskCompletion,
  setTaskPin,
  updateTask,
} from '../services/taskService.js';

export const taskRoutes = Router();

taskRoutes.use(requireAuth);

taskRoutes.get('/', async (req, res, next) => {
  try {
    const tasks = await getTasks({
      userId: req.authUser.id,
      date: req.query.date,
      pinned: req.query.pinned === 'true',
    });
    return res.json({ tasks });
  } catch (err) {
    return next(err);
  }
});

taskRoutes.get('/:id', async (req, res, next) => {
  try {
    const task = await getTaskById({
      userId: req.authUser.id,
      taskId: req.params.id,
    });
    return res.json({ task });
  } catch (err) {
    return next(err);
  }
});

taskRoutes.post('/', async (req, res, next) => {
  try {
    const task = await createTask({
      userId: req.authUser.id,
      input: req.body,
    });
    return res.status(201).json({ task });
  } catch (err) {
    return next(err);
  }
});

taskRoutes.patch('/:id', async (req, res, next) => {
  try {
    const task = await updateTask({
      userId: req.authUser.id,
      taskId: req.params.id,
      input: req.body,
    });
    return res.json({ task });
  } catch (err) {
    return next(err);
  }
});

taskRoutes.delete('/:id', async (req, res, next) => {
  try {
    await deleteTask({
      userId: req.authUser.id,
      taskId: req.params.id,
    });
    return res.json({ success: true });
  } catch (err) {
    return next(err);
  }
});

taskRoutes.patch('/:id/completion', async (req, res, next) => {
  try {
    const task = await setTaskCompletion({
      userId: req.authUser.id,
      taskId: req.params.id,
      completed: req.body.completed,
    });
    return res.json({ task });
  } catch (err) {
    return next(err);
  }
});

taskRoutes.patch('/:id/pin', async (req, res, next) => {
  try {
    const task = await setTaskPin({
      userId: req.authUser.id,
      taskId: req.params.id,
      pinned: req.body.pinned,
    });
    return res.json({ task });
  } catch (err) {
    return next(err);
  }
});
