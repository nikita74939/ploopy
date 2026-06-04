import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env.js';
import { achievementRoutes } from './routes/achievementRoutes.js';
import { activityRoutes } from './routes/activityRoutes.js';
import { authRoutes } from './routes/authRoutes.js';
import { dashboardRoutes } from './routes/dashboardRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';
import { eventRoutes } from './routes/eventRoutes.js';
import { friendRoutes } from './routes/friendRoutes.js';
import { notificationRoutes } from './routes/notificationRoutes.js';
import { scheduleRoutes } from './routes/scheduleRoutes.js';
import { settingsRoutes } from './routes/settingsRoutes.js';
import { streakRoutes } from './routes/streakRoutes.js';
import { studyRoutes } from './routes/studyRoutes.js';
import { taskRoutes } from './routes/taskRoutes.js';
import { userRoutes } from './routes/userRoutes.js';

const app = express();

app.use(helmet());
app.use(cors({ origin: env.appOrigin === '*' ? true : env.appOrigin }));
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

app.get('/health', (req, res) => res.json({ status: 'ok', app: 'ploopy-backend' }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/streaks', streakRoutes);
app.use('/api/study', studyRoutes);
app.use('/api/achievements', achievementRoutes);
app.use('/api/schedules', scheduleRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/dashboard', dashboardRoutes);

app.use((req, res) => res.status(404).json({ message: 'Route not found.' }));
app.use(errorHandler);

app.listen(env.port, () => console.log(`Ploopy backend running on http://localhost:${env.port}`));
