import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { getPublicUsers, getUserProfile, updateBiometricEnabled, updateUserProfile, uploadUserAvatar } from '../services/userService.js';
import { httpError } from '../utils/httpError.js';

export const userRoutes = Router();
userRoutes.use(requireAuth);

userRoutes.get('/search', async (req, res, next) => {
  try {
    const users = await getPublicUsers({ q: req.query.q, excludeUserId: req.authUser.id });
    return res.json({ users });
  } catch (err) { return next(err); }
});

userRoutes.get('/:id', async (req, res, next) => {
  try {
    const user = await getUserProfile(req.params.id);
    return res.json({ user });
  } catch (err) { return next(err); }
});

userRoutes.patch('/:id', async (req, res, next) => {
  try {
    if (req.authUser.id !== req.params.id) throw httpError(403, 'Tidak boleh mengubah user lain.');
    const user = await updateUserProfile({ userId: req.params.id, input: req.body });
    return res.json({ user });
  } catch (err) { return next(err); }
});

userRoutes.post('/:id/avatar', async (req, res, next) => {
  try {
    if (req.authUser.id !== req.params.id) throw httpError(403, 'Tidak boleh mengubah user lain.');
    const user = await uploadUserAvatar({ userId: req.params.id, input: req.body });
    return res.json({ user });
  } catch (err) { return next(err); }
});

userRoutes.patch('/:id/biometric', async (req, res, next) => {
  try {
    if (req.authUser.id !== req.params.id) throw httpError(403, 'Tidak boleh mengubah user lain.');
    if (typeof req.body.enabled !== 'boolean') throw httpError(400, 'Field enabled harus boolean.');
    const user = await updateBiometricEnabled({ userId: req.params.id, enabled: req.body.enabled });
    return res.json({ user });
  } catch (err) { return next(err); }
});
