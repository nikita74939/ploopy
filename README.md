# Ploopy

Flutter app with a Node.js + Express backend.

## Flutter setup

```bash
flutter pub get
cp .env.example .env
flutter run
```

Set `API_BASE_URL` in `.env`.

For Android emulator:

```text
API_BASE_URL=http://10.0.2.2:3000
```

For physical device, use your computer LAN IP:

```text
API_BASE_URL=http://192.168.x.x:3000
```

## Backend setup

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

The auth flow and main app features now go through HTTP requests to the Express
backend. Flutter stores session tokens in `flutter_secure_storage` and sends
them as Bearer tokens to the API. Supabase access is centralized behind the
backend services.

## Architecture

Flutter feature foldering follows `data-domain-presentation`. See
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the rules and the auth feature
as the reference implementation.
