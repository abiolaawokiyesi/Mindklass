-- ============================================================================
-- Data privacy lockdown — run this before letting real members of the public
-- use MindKlass.
-- ============================================================================
-- WHY THIS IS NEEDED:
-- A pre-launch audit found that most of the app's data-loading code asks
-- Supabase for "every row" in a table (direct_messages, behavior_notes, fees,
-- grades, attendance, assignments, assignment_submissions, meetings,
-- exam_apps, course_access_apps, exam_schedule, submissions) and then filters
-- what to *show* on the screen in JavaScript. That's fine for what a well-
-- behaved copy of the app displays — but it is NOT a security boundary. Row
-- Level Security (RLS) in the database is the only thing that actually stops
-- someone from opening their browser's developer console and querying, say,
-- every other family's private messages, disciplinary notes, or fee records
-- directly. Several of these tables had no RLS policy at all as far as we can
-- tell from the migrations run so far, meaning the only thing protecting that
-- data was the assumption that nobody would look. This migration closes that
-- gap table by table.
--
-- This does NOT fix the separate "fees can be self-marked paid without a real
-- Paystack webhook confirming it" issue — that's a genuine payment-integrity
-- gap, not a data-privacy one, and needs a server-side webhook, which is a
-- separate piece of work. This migration only makes sure people can't read or
-- write rows that aren't theirs.
-- ============================================================================

-- Reuses the public.is_admin() helper created in currency_referral_migration.sql.
-- Adds an equivalent helper for "is this caller a teacher".
create or replace function public.is_teacher()
returns boolean language sql security definer stable set search_path = public as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'teacher');
$$;

-- ── direct_messages (private 1:1 chat) ──────────────────────────────────────
alter table public.direct_messages enable row level security;
drop policy if exists "dm participants read" on public.direct_messages;
create policy "dm participants read" on public.direct_messages
  for select using (auth.uid() = from_id or auth.uid() = to_id or public.is_admin());
drop policy if exists "dm sender inserts as self" on public.direct_messages;
create policy "dm sender inserts as self" on public.direct_messages
  for insert with check (auth.uid() = from_id);
drop policy if exists "dm recipient marks read" on public.direct_messages;
create policy "dm recipient marks read" on public.direct_messages
  for update using (auth.uid() = to_id or public.is_admin())
  with check (auth.uid() = to_id or public.is_admin());

-- ── behavior_notes (sensitive student records) ──────────────────────────────
alter table public.behavior_notes enable row level security;
drop policy if exists "behavior notes visible to student/teacher/admin" on public.behavior_notes;
create policy "behavior notes visible to student/teacher/admin" on public.behavior_notes
  for select using (auth.uid() = student_id or auth.uid() = teacher_id or public.is_admin());
drop policy if exists "behavior notes written by teacher/admin" on public.behavior_notes;
create policy "behavior notes written by teacher/admin" on public.behavior_notes
  for insert with check (auth.uid() = teacher_id or public.is_admin());
drop policy if exists "behavior notes managed by admin" on public.behavior_notes;
create policy "behavior notes managed by admin" on public.behavior_notes
  for update using (public.is_admin()) with check (public.is_admin());
drop policy if exists "behavior notes deleted by admin" on public.behavior_notes;
create policy "behavior notes deleted by admin" on public.behavior_notes
  for delete using (public.is_admin());

-- ── fees (financial records) ────────────────────────────────────────────────
alter table public.fees enable row level security;
drop policy if exists "fees visible to student/admin" on public.fees;
create policy "fees visible to student/admin" on public.fees
  for select using (auth.uid() = student_id or public.is_admin());
drop policy if exists "fees created by admin" on public.fees;
create policy "fees created by admin" on public.fees
  for insert with check (public.is_admin());
-- NOTE: this still lets a student mark *their own* fee "paid" from the
-- client, matching today's app behaviour (see payFee/markFeePaid) — this
-- policy only stops them from touching someone else's fee record. Real
-- payment integrity still requires a Paystack webhook to set this status
-- server-side instead of trusting the browser.
drop policy if exists "fees updated by student/admin" on public.fees;
create policy "fees updated by student/admin" on public.fees
  for update using (auth.uid() = student_id or public.is_admin())
  with check (auth.uid() = student_id or public.is_admin());

-- ── grades ───────────────────────────────────────────────────────────────
alter table public.grades enable row level security;
drop policy if exists "grades visible to student/teacher/admin" on public.grades;
create policy "grades visible to student/teacher/admin" on public.grades
  for select using (auth.uid() = student_id or public.is_teacher() or public.is_admin());
drop policy if exists "grades written by teacher/admin" on public.grades;
create policy "grades written by teacher/admin" on public.grades
  for all using (public.is_teacher() or public.is_admin())
  with check (public.is_teacher() or public.is_admin());

-- ── attendance ───────────────────────────────────────────────────────────
alter table public.attendance enable row level security;
drop policy if exists "attendance visible to student/teacher/admin" on public.attendance;
create policy "attendance visible to student/teacher/admin" on public.attendance
  for select using (auth.uid() = student_id or public.is_teacher() or public.is_admin());
drop policy if exists "attendance self check-in" on public.attendance;
create policy "attendance self check-in" on public.attendance
  for insert with check (auth.uid() = student_id or public.is_admin());

-- ── classes (rosters) ────────────────────────────────────────────────────
alter table public.classes enable row level security;
drop policy if exists "classes visible to members/admin" on public.classes;
create policy "classes visible to members/admin" on public.classes
  for select using (auth.uid() = teacher_id or auth.uid() = any(student_ids) or public.is_admin());
drop policy if exists "classes managed by teacher/admin" on public.classes;
create policy "classes managed by teacher/admin" on public.classes
  for all using (auth.uid() = teacher_id or public.is_admin())
  with check (auth.uid() = teacher_id or public.is_admin());

-- ── assignments (class bulletin — lower sensitivity, readable by anyone
--    signed in; only the posting teacher or an admin can manage them) ───────
alter table public.assignments enable row level security;
drop policy if exists "assignments readable by any signed-in user" on public.assignments;
create policy "assignments readable by any signed-in user" on public.assignments
  for select using (auth.uid() is not null);
drop policy if exists "assignments managed by teacher/admin" on public.assignments;
create policy "assignments managed by teacher/admin" on public.assignments
  for all using (auth.uid() = teacher_id or public.is_admin())
  with check (auth.uid() = teacher_id or public.is_admin());

-- ── assignment_submissions ─────────────────────────────────────────────────
alter table public.assignment_submissions enable row level security;
drop policy if exists "submissions visible to student/teacher/admin" on public.assignment_submissions;
create policy "submissions visible to student/teacher/admin" on public.assignment_submissions
  for select using (auth.uid() = student_id or public.is_teacher() or public.is_admin());
drop policy if exists "submissions inserted by student/admin" on public.assignment_submissions;
create policy "submissions inserted by student/admin" on public.assignment_submissions
  for insert with check (auth.uid() = student_id or public.is_admin());
-- Students can resubmit before grading; teachers grade. A single table-level
-- policy can't restrict *which columns* an update touches, so this allows
-- both the owning student and any teacher/admin to update the row — good
-- enough to close the "anyone can grade anyone" gap; a fully airtight split
-- (student can only touch file_name, teacher can only touch grade/feedback)
-- would need a trigger, which we can add later if it matters.
drop policy if exists "submissions updated by student/teacher/admin" on public.assignment_submissions;
create policy "submissions updated by student/teacher/admin" on public.assignment_submissions
  for update using (auth.uid() = student_id or public.is_teacher() or public.is_admin())
  with check (auth.uid() = student_id or public.is_teacher() or public.is_admin());

-- ── meetings ────────────────────────────────────────────────────────────
alter table public.meetings enable row level security;
drop policy if exists "meetings readable by any signed-in user" on public.meetings;
create policy "meetings readable by any signed-in user" on public.meetings
  for select using (auth.uid() is not null);
drop policy if exists "meetings managed by host/admin" on public.meetings;
create policy "meetings managed by host/admin" on public.meetings
  for all using (auth.uid() = host_id or public.is_admin())
  with check (auth.uid() = host_id or public.is_admin());

-- ── notifications (admin broadcasts) ────────────────────────────────────────
alter table public.notifications enable row level security;
drop policy if exists "notifications readable by any signed-in user" on public.notifications;
create policy "notifications readable by any signed-in user" on public.notifications
  for select using (auth.uid() is not null);
drop policy if exists "notifications created by admin" on public.notifications;
create policy "notifications created by admin" on public.notifications
  for insert with check (public.is_admin());
drop policy if exists "notifications marked read by any signed-in user" on public.notifications;
create policy "notifications marked read by any signed-in user" on public.notifications
  for update using (auth.uid() is not null) with check (auth.uid() is not null);

-- ── community_messages (intentionally public chat channels) ────────────────
alter table public.community_messages enable row level security;
drop policy if exists "community messages readable by any signed-in user" on public.community_messages;
create policy "community messages readable by any signed-in user" on public.community_messages
  for select using (auth.uid() is not null);
drop policy if exists "community messages sent as self" on public.community_messages;
create policy "community messages sent as self" on public.community_messages
  for insert with check (auth.uid() = user_id);

-- ── course_access_apps / exam_apps (course & exam applications) ────────────
alter table public.course_access_apps enable row level security;
drop policy if exists "access apps visible to applicant/admin" on public.course_access_apps;
create policy "access apps visible to applicant/admin" on public.course_access_apps
  for select using (auth.uid() = user_id or public.is_admin());
drop policy if exists "access apps applied by self" on public.course_access_apps;
create policy "access apps applied by self" on public.course_access_apps
  for insert with check (auth.uid() = user_id);
drop policy if exists "access apps decided by admin" on public.course_access_apps;
create policy "access apps decided by admin" on public.course_access_apps
  for update using (public.is_admin()) with check (public.is_admin());

alter table public.exam_apps enable row level security;
drop policy if exists "exam apps visible to applicant/admin" on public.exam_apps;
create policy "exam apps visible to applicant/admin" on public.exam_apps
  for select using (auth.uid() = user_id or public.is_admin());
drop policy if exists "exam apps applied by self" on public.exam_apps;
create policy "exam apps applied by self" on public.exam_apps
  for insert with check (auth.uid() = user_id);
drop policy if exists "exam apps decided by admin" on public.exam_apps;
create policy "exam apps decided by admin" on public.exam_apps
  for update using (public.is_admin()) with check (public.is_admin());

-- ── exam_schedule (when a cohort's exam opens — not sensitive, admin-set) ──
alter table public.exam_schedule enable row level security;
drop policy if exists "exam schedule readable by any signed-in user" on public.exam_schedule;
create policy "exam schedule readable by any signed-in user" on public.exam_schedule
  for select using (auth.uid() is not null);
drop policy if exists "exam schedule managed by admin" on public.exam_schedule;
create policy "exam schedule managed by admin" on public.exam_schedule
  for all using (public.is_admin()) with check (public.is_admin());

-- ── submissions (assessment results for Teacher's Course / Student Subjects) ─
alter table public.submissions enable row level security;
drop policy if exists "submissions visible to owner/admin" on public.submissions;
create policy "submissions visible to owner/admin" on public.submissions
  for select using (auth.uid() = user_id or public.is_admin());
drop policy if exists "submissions submitted by self/admin" on public.submissions;
create policy "submissions submitted by self/admin" on public.submissions
  for insert with check (auth.uid() = user_id or public.is_admin());
drop policy if exists "submissions updated by self/admin" on public.submissions;
create policy "submissions updated by self/admin" on public.submissions
  for update using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());
