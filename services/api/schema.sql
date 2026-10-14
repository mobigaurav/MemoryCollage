-- Neon Postgres, applied in the next pass. The running API still
-- keeps credits and jobs in memory until DATABASE_URL is wired.

create table if not exists users (
  sub text primary key,
  email text,
  created_at timestamptz not null default now()
);

create table if not exists credit_events (
  id text primary key,
  sub text not null references users (sub),
  delta integer not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table if not exists video_jobs (
  id text primary key,
  sub text not null references users (sub),
  status text not null,
  style text,
  vendor text,
  vendor_job_id text,
  video_url text,
  error text,
  created_at timestamptz not null default now()
);
