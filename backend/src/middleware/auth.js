import jwt from 'jsonwebtoken';

import { env } from '../config/env.js';

export async function requireAuth(req, res, next) {
  const header = req.headers.authorization ?? '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Missing bearer token.' });
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.accessToken = token;
    req.authUser = {
      id: payload.sub,
      email: payload.email,
    };
    return next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token.' });
  }
}
