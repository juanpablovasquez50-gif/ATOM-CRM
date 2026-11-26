-- Internal CRM hardening and workspace bootstrap
create or replace function public.bootstrap_workspace()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_user uuid := auth.uid(); v_workspace uuid;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if exists (select 1 from public.workspace_members where user_id = v_user) then
    select workspace_id into v_workspace from public.workspace_members where user_id = v_user limit 1;
    return v_workspace;
  end if;
  insert into public.workspaces(name) values ('Atom Labs Workspace') returning id into v_workspace;
  insert into public.workspace_members(workspace_id,user_id,role) values (v_workspace,v_user,'admin');
  return v_workspace;
end;
$$;
revoke all on function public.bootstrap_workspace() from public, anon;
grant execute on function public.bootstrap_workspace() to authenticated;
drop policy if exists "users create own admin membership" on public.workspace_members;
drop policy if exists "authenticated create workspace" on public.workspaces;
drop policy if exists "members view their workspaces" on public.workspaces;
create policy "members view their workspaces" on public.workspaces for select to authenticated
using (exists (select 1 from public.workspace_members m where m.workspace_id = workspaces.id and m.user_id = auth.uid()));
drop policy if exists "admins update their workspaces" on public.workspaces;
create policy "admins update their workspaces" on public.workspaces for update to authenticated
using (exists (select 1 from public.workspace_members m where m.workspace_id = workspaces.id and m.user_id = auth.uid() and m.role = 'admin'))
with check (exists (select 1 from public.workspace_members m where m.workspace_id = workspaces.id and m.user_id = auth.uid() and m.role = 'admin'));
revoke execute on function public.handle_new_user() from public, anon, authenticated;
