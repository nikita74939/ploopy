import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env.js';
import { achievementRoutes } from './routes/achievementRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';
import { authRoutes } from './routes/authRoutes.js';
import { scheduleRoutes } from './routes/scheduleRoutes.js';
import { taskRoutes } from './routes/taskRoutes.js';
import { userRoutes } from './routes/userRoutes.js';

const app = express();

app.use(helmet());
app.use(cors({ origin: env.appOrigin }));
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use('/api/achievements', achievementRoutes);
app.use('/api/schedules', scheduleRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/users', userRoutes);

app.use((req, res) => {
  res.status(404).json({ message: 'Route not found.' });
});

app.use(errorHandler);

app.listen(env.port, () => {
  console.log(`Ploopy backend running on http://localhost:${env.port}`);
});
