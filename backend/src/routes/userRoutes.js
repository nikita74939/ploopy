import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { updateBiometricEnabled } from '../services/userService.js';
import { httpError } from '../utils/httpError.js';

export const userRoutes = Router();

userRoutes.patch('/:id/biometric', requireAuth, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { enabled } = req.body;

    if (req.authUser.id !== id) {
      throw httpError(403, 'Tidak boleh mengubah user lain.');
    }

    if (typeof enabled !== 'boolean') {
      throw httpError(400, 'Field enabled harus boolean.');
    }

    const user = await updateBiometricEnabled({ userId: id, enabled });
    return res.json({ user });
  } catch (err) {
    return next(err);
  }
});
