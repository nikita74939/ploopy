import { Router } from 'express';
import { supabase } from '../config/supabase.js';
import { requireAuth } from '../middleware/auth.js';
import { createUserProfile, getUserProfile } from '../services/userService.js';
import { httpError } from '../utils/httpError.js';

export const authRoutes = Router();

authRoutes.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw httpError(400, 'Email dan password wajib diisi.');
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error || !data.user || !data.session) {
      throw httpError(401, 'Email atau password salah.');
    }

    const user = await getUserProfile(data.user.id);

    return res.json({
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      expiresAt: data.session.expires_at,
      user,
    });
  } catch (err) {
    return next(err);
  }
});

authRoutes.post('/register', async (req, res, next) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
      throw httpError(400, 'Nama, email, dan password wajib diisi.');
    }

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });

    if (error || !data.user) {
      throw httpError(400, error?.message ?? 'Registrasi gagal.');
    }

    const user = await createUserProfile({
      id: data.user.id,
      email,
      name,
    });

    return res.status(201).json({
      token: data.session?.access_token ?? '',
      refreshToken: data.session?.refresh_token ?? '',
      expiresAt: data.session?.expires_at ?? null,
      user,
      requiresEmailConfirmation: !data.session,
    });
  } catch (err) {
    return next(err);
  }
});

authRoutes.post('/forgot-password', async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      throw httpError(400, 'Email wajib diisi.');
    }

    const { error } = await supabase.auth.resetPasswordForEmail(email);

    if (error) {
      throw httpError(400, error.message);
    }

    return res.json({ success: true });
  } catch (err) {
    return next(err);
  }
});

authRoutes.get('/me', requireAuth, async (req, res, next) => {
  try {
    const user = await getUserProfile(req.authUser.id);
    return res.json({ user });
  } catch (err) {
    return next(err);
  }
});

authRoutes.post('/logout', requireAuth, async (req, res) => {
  return res.json({ success: true });
});
