# Ploopy Backend Complete

Backend Node.js + Express untuk Ploopy dengan Supabase Postgres.

## Fitur API

- Auth manual: register, login, me, logout dengan bcrypt + JWT
- User profile + biometric flag
- App settings: dark mode, language, notification, app lock
- Streak belajar
- Achievement dan unlock user achievement
- Task CRUD, pin task, complete task
- Schedule CRUD, filter tanggal, upcoming
- Social activity feed, image URL, like, comment
- Friend request, accept/reject/block/remove
- Event CRUD, join/leave event
- Notification list, create, mark read, mark all read, delete
- Dashboard home gabungan untuk Flutter HomePage

## Setup

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

Isi `.env`:

```env
PORT=3000
APP_ORIGIN=*
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=xxxx
SUPABASE_SERVICE_ROLE_KEY=xxxx
JWT_SECRET=isi-random-panjang
```

## Database

Jalankan isi `sql/ploopy_public_schema.sql` di Supabase SQL Editor.

Kalau database kamu sudah dari `backup2.sql`, file SQL ini tetap aman karena pakai `create table if not exists`.

## Endpoint utama

Semua endpoint selain auth pakai header:

```http
Authorization: Bearer <token_dari_login>
```

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/logout`

### User

- `GET /api/users/search?q=nikita`
- `GET /api/users/:id`
- `PATCH /api/users/:id`
- `PATCH /api/users/:id/biometric`

### Settings & streak

- `GET /api/settings/me`
- `PATCH /api/settings/me`
- `GET /api/streaks/me`
- `POST /api/streaks/check-in`

### Home dashboard

- `GET /api/dashboard/home?date=2026-06-04`

### Tasks

- `GET /api/tasks`
- `GET /api/tasks?date=2026-06-04`
- `GET /api/tasks?pinned=true`
- `POST /api/tasks`
- `PATCH /api/tasks/:id`
- `PATCH /api/tasks/:id/completion`
- `PATCH /api/tasks/:id/pin`
- `DELETE /api/tasks/:id`

### Schedules

- `GET /api/schedules`
- `GET /api/schedules?date=2026-06-04`
- `GET /api/schedules?upcoming=true`
- `POST /api/schedules`
- `PATCH /api/schedules/:id`
- `DELETE /api/schedules/:id`

### Achievements

- `GET /api/achievements`
- `GET /api/achievements/users/:userId`
- `POST /api/achievements/users/:userId`

### Activities

- `GET /api/activities`
- `GET /api/activities?mine=true`
- `POST /api/activities`
- `POST /api/activities/:id/like`
- `POST /api/activities/:id/comments`
- `DELETE /api/activities/comments/:id`
- `DELETE /api/activities/:id`

### Friends

- `GET /api/friends`
- `POST /api/friends`
- `PATCH /api/friends/:id`
- `DELETE /api/friends/:id`

### Events

- `GET /api/events`
- `GET /api/events?upcoming=true`
- `GET /api/events/:id`
- `POST /api/events`
- `PATCH /api/events/:id`
- `DELETE /api/events/:id`
- `POST /api/events/:id/join`
- `DELETE /api/events/:id/join`

### Notifications

- `GET /api/notifications`
- `GET /api/notifications?unread=true`
- `POST /api/notifications`
- `PATCH /api/notifications/:id/read`
- `PATCH /api/notifications/read-all`
- `DELETE /api/notifications/:id`
