import { Router } from 'express';
import bcrypt from 'bcrypt';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';

import { env } from '../config/env.js';
import { requireAuth } from '../middleware/auth.js';
import {
  createUserProfile,
  getUserByEmailWithPassword,
  getUserProfile,
} from '../services/userService.js';
import { httpError } from '../utils/httpError.js';

export const authRoutes = Router();

const tokenTtlSeconds = 60 * 60 * 24 * 7;
const bcryptSaltRounds = 10;

function createAuthPayload(user) {
  const expiresAt = Math.floor(Date.now() / 1000) + tokenTtlSeconds;
  const token = jwt.sign(
    { email: user.email },
    env.jwtSecret,
    {
      subject: user.id,
      expiresIn: tokenTtlSeconds,
    },
  );

  return {
    token,
    refreshToken: '',
    expiresAt,
    user,
  };
}

authRoutes.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw httpError(400, 'Email dan password wajib diisi.');
    }

    const normalizedEmail = email.trim().toLowerCase();
    const userWithPassword = await getUserByEmailWithPassword(normalizedEmail);

    if (!userWithPassword?.password_hash) {
      throw httpError(401, 'Email atau password salah.');
    }

    const isValidPassword = await bcrypt.compare(
      password,
      userWithPassword.password_hash,
    );

    if (!isValidPassword) {
      throw httpError(401, 'Email atau password salah.');
    }

    const user = await getUserProfile(userWithPassword.id);
    return res.json(createAuthPayload(user));
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

    if (password.length < 6) {
      throw httpError(400, 'Password minimal 6 karakter.');
    }

    const normalizedEmail = email.trim().toLowerCase();
    const normalizedName = name.trim();

    if (!normalizedName) {
      throw httpError(400, 'Nama wajib diisi.');
    }

    const existingUser = await getUserByEmailWithPassword(normalizedEmail);

    if (existingUser) {
      throw httpError(400, 'Email sudah terdaftar.');
    }

    const passwordHash = await bcrypt.hash(password, bcryptSaltRounds);
    const user = await createUserProfile({
      id: crypto.randomUUID(),
      email: normalizedEmail,
      name: normalizedName,
      passwordHash,
    });

    return res.status(201).json(createAuthPayload(user));
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
