# Production readiness plan — Atom CRM

## Current status
- Static React/Vite app hosted on Render.
- Login is a demo gate only; no real identity verification.
- CRM records are stored in browser localStorage and are not shared/synced.
- Repository is public. Never commit real client data, passwords, API keys, or service-role keys.

## Production architecture target
1. Supabase Auth (real sign-in, password reset, session management).
2. Supabase Postgres for leads, tasks, client records, activity history, and settings.
3. Row Level Security (RLS) on all exposed tables; workspace membership and roles enforced in database policies.
4. Frontend uses only the publishable key and public project URL. Never ship service-role/secret keys.
5. Automated checks: TypeScript build, lint, tests, dependency audit, and deployment verification.
6. Backups, monitoring, error reporting, and a recovery plan before real business data is entered.

## Release gates
- [ ] Choose/create dedicated production Supabase project (do not reuse an unrelated project without explicit approval).
- [ ] Apply reviewed database migrations and confirm RLS policies.
- [ ] Implement real Auth and protected routes; remove demo login.
- [ ] Replace localStorage persistence with database-backed CRUD and loading/error states.
- [ ] Add user roles (admin, commercial, operations) with server/database enforcement.
- [ ] Add audit trail and safe deletion/restore strategy.
- [ ] Add tests for auth, data isolation, CRUD, and critical flows.
- [ ] Configure environment variables in Render.
- [ ] Verify production deployment and smoke test.
- [ ] Set repository visibility/private access if the owner decides; repository currently public.

## Data model target
- workspaces
- workspace_members (role and membership)
- profiles
- leads (company/contact/service/stage/value/priority/city/follow-up)
- tasks (workspace, assigned user, lead relation, due date, status)
- activity_log (auditable events)
