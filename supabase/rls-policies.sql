-- =============================================================================
-- Wedding photo gallery - row level security
-- =============================================================================
-- Apply once, as a single script: Supabase dashboard -> SQL Editor -> New query
-- -> paste -> Run. Then upload a test photo from a phone and confirm it still
-- appears in the guest gallery. Run this BEFORE the reception, not during it.
--
-- What this does and does not do:
--   * Guests keep working exactly as they do now - they upload and see their
--     own photos with the public anon key, no login.
--   * Photos stay publicly viewable. They live in a public storage bucket, so
--     anyone holding a link can already open one; that is unchanged.
--   * What changes is destruction. Today the anon key can delete rows and
--     objects, which means anyone who views source could clear the gallery
--     mid-reception. After this, only a signed-in admin can.
-- =============================================================================

alter table public.uploads enable row level security;

-- Guests submit photo records from the browser.
drop policy if exists "guests can insert uploads" on public.uploads;
create policy "guests can insert uploads"
  on public.uploads for insert
  to anon, authenticated
  with check (true);

-- Guests read their own gallery back (index.html filters by name + table), and
-- the admin page reads everything. The photo URLs are public either way.
drop policy if exists "anyone can read uploads" on public.uploads;
create policy "anyone can read uploads"
  on public.uploads for select
  to anon, authenticated
  using (true);

-- Edits and removals require a real account. No anon policy is defined for
-- update or delete, so under RLS those are denied by default.
drop policy if exists "admins can update uploads" on public.uploads;
create policy "admins can update uploads"
  on public.uploads for update
  to authenticated
  using (true)
  with check (true);

drop policy if exists "admins can delete uploads" on public.uploads;
create policy "admins can delete uploads"
  on public.uploads for delete
  to authenticated
  using (true);

-- -----------------------------------------------------------------------------
-- Storage objects - same shape: guests add, only admins remove.
-- -----------------------------------------------------------------------------

drop policy if exists "guests can upload photos" on storage.objects;
create policy "guests can upload photos"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'photos');

drop policy if exists "photos are publicly readable" on storage.objects;
create policy "photos are publicly readable"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'photos');

drop policy if exists "admins can delete photos" on storage.objects;
create policy "admins can delete photos"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'photos');
