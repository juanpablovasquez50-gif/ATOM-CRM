-- Remove an older permissive workspace update policy that allowed all members to update workspace metadata.
drop policy if exists "members update workspace" on public.workspaces;
