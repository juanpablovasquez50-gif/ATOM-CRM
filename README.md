# Atom CRM

CRM interno de Atom Labs.

## Development
```bash
npm install
npm run dev
```

## Build
```bash
npm run build
```

## Current limitations — not production-ready yet
- Demo login is not real authentication.
- Data is stored in localStorage per browser and is not shared or backed up.
- No backend, roles, or database access controls yet.
- Do not enter confidential client data or production credentials.

## Production migration
See [PRODUCTION_READINESS.md](./PRODUCTION_READINESS.md). Production work is being prepared in a separate branch so main remains stable.

## Environment
Copy `.env.example` to `.env.local` after the dedicated Supabase production project is selected. Never commit populated environment files or service-role/secret keys.
