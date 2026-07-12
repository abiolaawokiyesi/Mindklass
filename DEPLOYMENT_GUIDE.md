# MindKlass — Deployment Guide (GitHub → Vercel)

This guide takes you from the files in this folder to a **live URL** on Vercel. No prior deployment experience is assumed. Follow the sections in order.

**What you'll end up with:** a public website like `https://mindklass.vercel.app` that redeploys automatically every time you push to GitHub.

---

## Table of contents

1. [Before you start](#1-before-you-start)
2. [Install the tools](#2-install-the-tools)
3. [Test the build locally (recommended)](#3-test-the-build-locally-recommended)
4. [Put the project on GitHub](#4-put-the-project-on-github)
5. [Deploy on Vercel](#5-deploy-on-vercel)
6. [Add a custom domain (optional)](#6-add-a-custom-domain-optional)
7. [Updating the live site](#7-updating-the-live-site)
8. [Troubleshooting](#8-troubleshooting)
9. [Production hardening checklist](#9-production-hardening-checklist)

---

## 1. Before you start

Create these two free accounts if you don't have them:

- **GitHub** — https://github.com/signup (hosts your code)
- **Vercel** — https://vercel.com/signup → choose **"Continue with GitHub"** (this links the two, which makes deployment one click)

You should have received the project as a folder containing `package.json`, `index.html`, `vite.config.js`, `vercel.json`, and the `src/` and `public/` folders. Keep them together exactly as they are.

---

## 2. Install the tools

You need two programs on your computer:

### Node.js (version 18 or newer)
Download the **LTS** version from https://nodejs.org and install it. To confirm it worked, open a terminal (Command Prompt / PowerShell on Windows, Terminal on macOS) and run:

```bash
node --version
```

You should see something like `v20.x.x`. Any version 18 or above is fine.

### Git
Download from https://git-scm.com/downloads and install with the default options. Confirm with:

```bash
git --version
```

---

## 3. Test the build locally (recommended)

This step proves everything works **before** you involve GitHub or Vercel, so any problem is caught early. In your terminal, navigate into the project folder and run:

```bash
cd path/to/mindklass      # replace with the actual folder path
npm install               # downloads dependencies (takes ~30 seconds)
npm run dev               # starts a local server
```

Open the URL it prints (usually **http://localhost:5173**) in your browser. You should see the MindKlass login screen. Sign in with a demo account (e.g. teacher `john@mindklass.com` / `teach123`) to check it works.

Press `Ctrl + C` in the terminal to stop the server. Then verify the **production** build compiles:

```bash
npm run build
```

You should see `✓ built in ...s` and a new `dist/` folder appear. If this succeeds, Vercel will succeed too. (You can delete `dist/` afterward — it's regenerated automatically and is excluded from Git.)

> **If `npm install` or `npm run build` fails,** jump to [Troubleshooting](#8-troubleshooting) before continuing.

---

## 4. Put the project on GitHub

You have two options. **Option A (website upload)** is easiest if you're not comfortable with the command line. **Option B (Git commands)** is faster for future updates.

### Option A — Upload through the GitHub website

1. Go to https://github.com/new
2. **Repository name:** `mindklass` (or any name you like).
3. Set it to **Private** or **Public** — your choice. Both work with Vercel.
4. **Do not** tick "Add a README" (the project already has one). Click **Create repository**.
5. On the next page, click the link **"uploading an existing file"**.
6. Drag the **contents** of the project folder into the upload area — that is, drag `package.json`, `index.html`, `src`, `public`, etc. **Do not** drag the `node_modules` or `dist` folders (if they exist, skip them). Do not zip the folder; upload the files/folders directly.
7. Scroll down and click **Commit changes**.

Your code is now on GitHub. Skip to [Section 5](#5-deploy-on-vercel).

### Option B — Push with Git commands

From inside the project folder, run:

```bash
git init
git add .
git commit -m "Initial commit — MindKlass"
git branch -M main
```

Then create an empty repo at https://github.com/new (name it `mindklass`, don't add a README), and copy the two commands GitHub shows under **"…or push an existing repository from the command line"**. They look like this — replace `YOUR-USERNAME`:

```bash
git remote add origin https://github.com/YOUR-USERNAME/mindklass.git
git push -u origin main
```

Refresh the GitHub page; your files should appear.

> **Note:** the `.gitignore` file already excludes `node_modules/` and `dist/`, so those large folders won't be uploaded even if they exist locally. That's intentional and correct.

---

## 5. Deploy on Vercel

1. Go to https://vercel.com and sign in with GitHub.
2. Click **Add New…** → **Project**.
3. You'll see a list of your GitHub repositories. Find **mindklass** and click **Import**.
   - If it's not listed, click **"Adjust GitHub App Permissions"** / **"Configure GitHub App"** and grant Vercel access to the repo, then return.
4. On the configuration screen, Vercel auto-detects the settings from `vercel.json`. You should see:
   - **Framework Preset:** Vite
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   
   Leave these as they are. You do **not** need to add any Environment Variables — the app has none.
5. Click **Deploy**.

Wait about a minute while Vercel installs dependencies and builds. When it finishes you'll see a **"Congratulations"** screen with a preview thumbnail and a URL like `https://mindklass.vercel.app`.

Click **Visit** (or **Continue to Dashboard** → **Visit**) to open your live site. 🎉

---

## 6. Add a custom domain (optional)

If you own a domain (e.g. `mindklass.com`):

1. In your project on Vercel, open the **Settings** tab → **Domains**.
2. Type your domain and click **Add**.
3. Vercel shows the DNS records to set. Log in to wherever you bought the domain (GoDaddy, Namecheap, etc.) and add the records exactly as shown — usually:
   - an **A record** for the root domain pointing to Vercel's IP, and/or
   - a **CNAME record** for `www` pointing to `cname.vercel-dns.com`.
4. Back on Vercel, wait for the domain status to turn green (DNS can take from minutes up to a few hours). Vercel provisions HTTPS automatically.

---

## 7. Updating the live site

Vercel watches your GitHub repo. **Every push to the `main` branch triggers a new deployment automatically** — you never manually redeploy.

- **If you used Option A (website):** open your repo on GitHub, navigate to the file you want to change (e.g. `src/MindKlass.jsx`), click the pencil ✏️ icon, edit, and **Commit changes**. Vercel redeploys within a minute.
- **If you used Option B (Git):** edit files locally, then:

  ```bash
  git add .
  git commit -m "Describe your change"
  git push
  ```

You can watch each deployment's progress in the Vercel dashboard under the **Deployments** tab. If a build ever fails, the **currently live version stays up** — a broken build never takes your site down.

---

## 8. Troubleshooting

**`npm install` fails with permission or network errors.**
Make sure you have a stable internet connection. On corporate networks, a proxy/firewall may block npm — try a different network. Delete any partial `node_modules` folder and the `package-lock.json`, then run `npm install` again.

**`npm run build` fails locally.**
Confirm your Node version is 18+ (`node --version`). Delete `node_modules` and `package-lock.json`, run `npm install`, then `npm run build` again. Read the first error message printed — it usually names the file and line.

**Vercel build fails but local build works.**
This is almost always a Node-version mismatch. In Vercel: **Settings → General → Node.js Version**, set it to **20.x**, then **Deployments → ⋯ → Redeploy**. Also confirm `package-lock.json` was committed to GitHub (it should be — only `node_modules` and `dist` are git-ignored).

**The site loads but the page is blank / white screen.**
Open the browser's developer console (F12) and read the error. The most common cause is a file that didn't get uploaded. Confirm on GitHub that `src/MindKlass.jsx`, `src/main.jsx`, and `index.html` are all present.

**Refreshing a page gives a 404.**
This shouldn't happen — `vercel.json` includes an SPA rewrite that sends all routes to `index.html`. If it does, confirm `vercel.json` was uploaded to GitHub and redeploy.

**The logo or certificate signature doesn't appear.**
Confirm `public/MINDKLASS_LOGO_2.png` and `public/Abiola_signature.png` were uploaded to GitHub. Files in `public/` are served from the site root (e.g. `/MINDKLASS_LOGO_2.png`).

**Images in `public/` return 404 on the live site.**
File names are case-sensitive on Vercel. Ensure the file name on GitHub matches exactly (including capitals and the `.png` extension).

---

## 9. Production hardening checklist

The site is fully functional as deployed, but before a real public launch, complete these (each is optional and independent):

1. **Paystack webhook (payment trust).** The app currently redirects to Paystack and optimistically marks a fee paid on return. For production-grade trust, stand up a small backend endpoint that verifies incoming `charge.success` events using the `x-paystack-signature` header, and reconcile payment status from there. This repo is frontend-only, so the webhook lives in a separate service (e.g. a serverless function).

2. **Push notifications (Firebase Cloud Messaging).** FCM is coded but disabled. To enable:
   - Create a Firebase project and a Web app; copy its config.
   - Paste the config into **both** `src/MindKlass.jsx` (the `FIREBASE_CONFIG` object) **and** `public/firebase-messaging-sw.js`.
   - Set `FCM_ENABLED = true` in `src/MindKlass.jsx`.
   - Commit and push. The service worker at `/firebase-messaging-sw.js` is already served at the correct location.

3. **Custom domain + HTTPS.** Covered in [Section 6](#6-add-a-custom-domain-optional). HTTPS is automatic on Vercel.

4. **Analytics (optional).** Vercel offers one-click Web Analytics under the project's **Analytics** tab if you want traffic insight.

---

### Quick reference

| Task | Command / Action |
|---|---|
| Install deps | `npm install` |
| Run locally | `npm run dev` → http://localhost:5173 |
| Build | `npm run build` |
| Preview build | `npm run preview` |
| Push update (Git) | `git add . && git commit -m "..." && git push` |
| Redeploy | Automatic on every push to `main` |

You're live. Any change you push to GitHub is on the internet within a minute.
