-- In-app account deletion (Apple App Store 5.1.1(v) / Google Play).
-- The app calls `supabase.rpc('delete_user')` from Account → "حذف الحساب والبيانات".
-- Run this once in the Supabase SQL editor. It deletes ONLY the calling user.

create or replace function public.delete_user()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  -- Personal data first (reports keep no author link afterwards).
  update public.restoration_logs set expert_id = null where expert_id = uid;
  delete from auth.users where id = uid;
end;
$$;

revoke all on function public.delete_user() from public, anon;
grant execute on function public.delete_user() to authenticated;
