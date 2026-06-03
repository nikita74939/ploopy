# Ploopy Backend

Node.js + Express API layer for Ploopy.

## Setup

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

Default server URL:

```text
http://localhost:3000
```

For Android emulator, use this base URL in Flutter:

```text
http://10.0.2.2:3000
```

## Endpoints

- `GET /health`
- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/forgot-password`
- `GET /api/auth/me`
- `POST /api/auth/logout`
- `PATCH /api/users/:id/biometric`
