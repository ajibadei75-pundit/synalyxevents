# Event registration, flier and certificate app

Static site (`index.html`) + Supabase backend (already created and configured).

## Admin sign-in
- URL: `/admin`
- Email: ajibadei75@gmail.com
- Temporary password: `Synalyx#Admin2026` -- change it immediately: Overview > Change password.

## Deploy
- Install as an app: on phones use "Add to Home Screen"; on desktop Chrome/Edge use the Install app button in the header.
- Vercel: `vercel --prod` in this folder (or import it). `vercel.json` rewrites all paths to index.html.
- Netlify: drag the folder in. `netlify.toml` does the same.
- The Supabase URL and anon key are already in `index.html` (`CFG`). The anon key is public by design; never use the service_role key.

## First-time steps
1. Sign in at `/admin`, change the password.
2. Event tab: details, logo, colours, font. Save each card.
3. Flier and Certificate tabs: upload templates, click/drag to place items, Save. Tick "Release certificates" when ready.
4. Registration tab: copy the link or QR code and share it.
5. Attendees tab: approve (single, selected, or all pending), then tick Flier and/or Certificate per attendee, or use "Apply access to selected" for groups (both, flier only, certificate only, none). Attendees open `/portal` with their email.

## Security notes and limitations
- Flier and certificate templates are not publicly readable; the server returns them only to approved attendees (certificate only when released).
- The portal identifies attendees by email only (no password or email code). Anyone who knows an approved attendee's email can download that person's flier/certificate. For stronger protection add email one-time codes via Supabase Auth.
- Supabase Auth setting to enable in the dashboard: Authentication > Passwords > leaked password protection.
- Templates are stored as compressed images in the database; keep each under about 1 MB.
- Not verified in a real browser by the author: run the checklist on your live site (register, approve, download PDF and JPEG, change logo/colours, phone and dark mode).
