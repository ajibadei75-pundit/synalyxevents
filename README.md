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
5. Attendees tab: approve (single, selected, or all pending), then use the Access dropdown on each row (Flier + certificate, Flier only, Certificate only, No access), or "Set access for selected" for groups. Registration tab > default access sets what newly approved attendees receive. Attendees open `/portal` with their email.

## Security notes and limitations
- Flier and certificate templates are not publicly readable; the server returns them only to approved attendees (certificate only when released).
- The portal identifies attendees by email only (no password or email code). Anyone who knows an approved attendee's email can download that person's flier/certificate. For stronger protection add email one-time codes via Supabase Auth.
- Supabase Auth setting to enable in the dashboard: Authentication > Passwords > leaked password protection.
- Templates are stored as compressed images in the database; keep each under about 1 MB.
- Not verified in a real browser by the author: run the checklist on your live site (register, approve, download PDF and JPEG, change logo/colours, phone and dark mode).

## Install as an app and badge alerts
- Android/Chrome/Edge/desktop: use the Install app button in the header. iPhone/iPad: Safari > Share > Add to Home Screen (iOS 16.4+ is needed for badges and alerts, and only for the installed app).
- Admin: the app icon and browser tab show the number of attendees waiting for approval, the Attendees tab shows a red count, and a pop-up alert appears when someone registers (turn on Overview > Enable notifications). Updates are instant through Supabase Realtime, with a 30-second check as backup.
- Attendees: when the app is opened or brought back to the front, a badge and alert appear if they have been approved or their certificate is ready.
- Limitation: alerts only arrive while the app or browser tab is open or running in the background. Alerts to a fully closed app need a push server (web-push with VAPID keys and a Supabase Edge Function), which is not included. Badge support depends on the device and browser.
