import { Router } from 'express';
import { supabase, supabaseAdmin } from '../config/supabase.js';
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

    const { data: created, error: createError } =
      await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });

    if (createError || !created.user) {
      throw httpError(400, createError?.message ?? 'Registrasi gagal.');
    }

    const user = await createUserProfile({
      id: created.user.id,
      email,
      name,
    });

    const { data: sessionData, error: sessionError } =
      await supabase.auth.signInWithPassword({
        email,
        password,
      });

    if (sessionError || !sessionData.session) {
      throw httpError(500, 'Akun dibuat, tetapi login otomatis gagal.');
    }

    return res.status(201).json({
      token: sessionData.session.access_token,
      refreshToken: sessionData.session.refresh_token,
      expiresAt: sessionData.session.expires_at,
      user,
    });
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
