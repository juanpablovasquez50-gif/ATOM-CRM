-- ATOM CRM expansion: commercial intelligence, proposals, projects and finance
create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete set null,
  actor_id uuid references auth.users(id) on delete set null,
  activity_type text not null check (activity_type in ('note','call','whatsapp','email','meeting','proposal','stage_change','system')),
  title text not null,
  details text,
  created_at timestamptz not null default now()
);
create table if not exists public.quotes (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete set null,
  client_name text not null,
  quote_number text not null,
  title text not null,
  items jsonb not null default '[]'::jsonb,
  subtotal numeric not null default 0,
  discount numeric not null default 0,
  total numeric not null default 0,
  status text not null default 'draft' check (status in ('draft','sent','accepted','rejected','expired')),
  expires_at date,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete set null,
  client_name text not null,
  name text not null,
  description text,
  status text not null default 'planning' check (status in ('planning','in_progress','review','completed','paused')),
  start_date date,
  due_date date,
  budget numeric not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid references public.projects(id) on delete set null,
  lead_id uuid references public.leads(id) on delete set null,
  client_name text not null,
  description text,
  amount numeric not null,
  payment_date date,
  status text not null default 'pending' check (status in ('pending','paid','overdue')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid references public.projects(id) on delete set null,
  description text not null,
  category text not null default 'General',
  amount numeric not null,
  expense_date date not null default current_date,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.sales_goals (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  title text not null,
  goal_type text not null check (goal_type in ('revenue','leads','meetings','wins')),
  target numeric not null,
  period_start date not null,
  period_end date not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.reminders (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete cascade,
  title text not null,
  due_at timestamptz not null,
  completed boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.activities enable row level security;
alter table public.quotes enable row level security;
alter table public.projects enable row level security;
alter table public.payments enable row level security;
alter table public.expenses enable row level security;
alter table public.sales_goals enable row level security;
alter table public.reminders enable row level security;
do $$
declare t text;
begin
 foreach t in array array['activities','quotes','projects','payments','expenses','sales_goals','reminders'] loop
   execute format('drop policy if exists workspace_member_access on public.%I',t);
   execute format('create policy workspace_member_access on public.%I for all using (exists (select 1 from public.workspace_members wm where wm.workspace_id = %I.workspace_id and wm.user_id = auth.uid())) with check (exists (select 1 from public.workspace_members wm where wm.workspace_id = %I.workspace_id and wm.user_id = auth.uid()))',t,t,t);
 end loop;
end $$;
create index if not exists activities_workspace_created_idx on public.activities(workspace_id,created_at desc);
create index if not exists quotes_workspace_status_idx on public.quotes(workspace_id,status);
create index if not exists projects_workspace_status_idx on public.projects(workspace_id,status);
create index if not exists payments_workspace_status_idx on public.payments(workspace_id,status);
create index if not exists reminders_workspace_due_idx on public.reminders(workspace_id,due_at);
