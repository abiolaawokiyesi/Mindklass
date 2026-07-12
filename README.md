# MindKlass · Live Ideally

Cambridge IGCSE online learning and **teacher training & certification** platform, built by PATHFINDER.

MindKlass is a single-page React application (Vite + React 18) with four role-based experiences — **student, teacher, parent, admin** — covering live classes, educational games, assignments, a gradebook, attendance, community and private messaging, an offline-first sync engine, a pressure-sensitive whiteboard, and a full **Teacher Training & Certification** system for IGCSE subjects.

---

## Tech stack

| Layer | Choice |
|---|---|
| Framework | React 18 |
| Build tool | Vite 5 |
| Icons | `lucide-react` (pinned to 0.383.0) |
| Styling | Inline theming via the `mkT(dark)` token function — no CSS framework |
| Payments | Paystack redirect (`paystack.shop/pay/Mindklass`) |
| Push (optional) | Firebase Cloud Messaging, gated behind `FCM_ENABLED` (off by default) |
| Hosting | Vercel (static SPA) |

There is **no backend in this repository** — the app runs entirely client-side, persisting session/offline data in `localStorage`.

---

## Getting started (local)

Requires **Node.js 18+**.

```bash
npm install      # install dependencies
npm run dev      # start the dev server (http://localhost:5173)
npm run build    # production build → dist/
npm run preview  # preview the production build locally
```

## Demo credentials

| Role | Email | Password |
|---|---|---|
| Student | `sarah@mindklass.com` | `learn123` |
| Teacher | `john@mindklass.com` | `teach123` |
| Parent | `wei@mindklass.com` | `parent123` |
| Admin | `admin@mindklass.com` | `admin123` |

---

## Deploying

See **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** for step-by-step instructions to push this repo to GitHub and go live on Vercel.

The short version: push to GitHub → import the repo in Vercel → deploy. Vercel auto-detects Vite; `vercel.json` already sets the build command, output directory, and SPA rewrite.

---

## Teacher Training & Certification

Available to **teachers and admins** under the *Training & Certification* (teachers) / *Certifications* (admins) tab. Each course:

- is grounded in the real Cambridge syllabus, specimen/June papers and mark schemes,
- has **6 CPD units**, each gated by a two-question knowledge check,
- ends with a **100-question expert assessment** pitched at examiner/standardisation level, with a **75% pass mark**,
- shows results (score, pass/fail, per-objective breakdown, printable certificate) **immediately on submission**.

Courses currently included: **English as a Second Language (0510)** and **Sociology (0495)**. The data layer is subject-agnostic — new subjects are added as entries in the `TRAININGS` registry.

---

## Project structure

```
.
├── index.html                 # HTML entry (fonts, favicon, root div)
├── package.json               # dependencies + scripts
├── vite.config.js             # Vite + React plugin config
├── vercel.json                # Vercel build + SPA rewrite
├── public/
│   ├── MINDKLASS_LOGO_2.png    # brand logo (favicon + header)
│   ├── Abiola_signature.png    # director's signature (certificates)
│   └── firebase-messaging-sw.js# FCM service worker (inert until enabled)
└── src/
    ├── main.jsx               # React entry — mounts <MindKlass/>
    ├── MindKlass.jsx          # the entire application (single component)
    └── index.css              # global reset + print styles
```

---

## Production checklist

Items to complete before a full production launch (see the deployment guide for detail):

- [ ] Add a backend **Paystack webhook** to verify `charge.success` via the `x-paystack-signature` header.
- [ ] Fill real Firebase credentials in `src/MindKlass.jsx` **and** `public/firebase-messaging-sw.js`, then flip `FCM_ENABLED = true`.
- [ ] Replace the CSS-drawn certificate signature/logo placeholders with the real image assets if desired.
- [ ] Point a custom domain at the Vercel deployment.

---

© PATHFINDER · MindKlass. Director: Mr. Abiola Awokiyesi.
