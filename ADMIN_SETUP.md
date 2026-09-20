# Admin setup

The admin page no longer has a password baked into it. It signs in against
Supabase Auth instead, so the credential never ships in the page source.

## One-time setup

1. **Create the admin account.**
   Supabase dashboard -> Authentication -> Users -> *Add user* -> *Create new user*.
   Use a real email and a strong password, and tick **Auto Confirm User** so it
   works without an email round-trip.

2. **Apply the database policies.**
   SQL Editor -> New query -> paste all of [`supabase/rls-policies.sql`](supabase/rls-policies.sql) -> Run.
   Run the whole file at once; the policies only make sense together.

3. **Turn off public signups**, so the login page can't be used to mint new accounts.
   Authentication -> Providers -> Email -> disable *Enable sign ups*.

## Verify before the day

Work through all four, ideally from a phone on cell data rather than home wifi:

- [ ] Upload a photo as a guest (`index.html?table=1`) - still works, no login.
- [ ] The photo appears in the guest's own gallery.
- [ ] `admin.html` rejects a wrong password and accepts the real account.
- [ ] Sign Out returns you to the login screen and a reload keeps you signed out.

If uploads break after step 2, the fastest rollback is
`alter table public.uploads disable row level security;` - that restores
today's behaviour while you work out which policy is wrong.

## What is and isn't protected

Photos stay **publicly viewable**: they're served from a public storage bucket,
so anyone with a link can open one. That was already true and this change
doesn't alter it.

What changes is that photos can no longer be **deleted** by anyone holding the
public anon key - which, before this, included anyone who opened devtools.
