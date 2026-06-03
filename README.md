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

The auth flow now goes through HTTP requests to the Express backend. Some older
features still use Supabase directly and can be migrated route by route.

## Architecture

Flutter feature foldering follows `data-domain-presentation`. See
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the rules and the auth feature
as the reference implementation.
