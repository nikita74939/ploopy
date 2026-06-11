import { getSchedules } from './scheduleService.js';
import { getTasks } from './taskService.js';
import { getStreak } from './streakService.js';
import { getUserAchievements } from './achievementService.js';
import { getNotifications } from './notificationService.js';

export async function getHomeDashboard(userId, date) {
  const [schedules, tasks, streak, achievements, notifications] = await Promise.all([
    getSchedules({ userId, date, upcoming: false }),
    getTasks({ userId, date, pinned: false }),
    getStreak(userId),
    getUserAchievements(userId),
    getNotifications({ userId, unreadOnly: true }),
  ]);

  const upcomingSchedules = schedules.filter((item) => Date.parse(item.start_time) >= Date.now());
  const incompleteTasks = tasks.filter((item) => !item.is_completed);

  return {
    date,
    schedules,
    tasks,
    streak,
    achievements,
    unreadNotifications: notifications.length,
    nextSchedule: upcomingSchedules[0] ?? null,
    urgentTask: incompleteTasks[0] ?? null,
  };
}
