-- 0001_init.sql — Comfy-MBM pipeline core schema (Supabase / Postgres 15+)
-- Status values must stay identical to CLAUDE.md and docs/DATA-MODEL.md.
-- Apply once in the Supabase SQL editor (or `supabase db push`). Never edit after applying; add 000N_*.sql.
-- Storage: create a PRIVATE bucket named by SUPABASE_STORAGE_BUCKET (default mbm-media) in the dashboard.

create extension if not exists pgcrypto;
-- create extension if not exists vector;   -- enable later for semantic memory (see docs/DATA-MODEL.md)

-- ---------------------------------------------------------------- helpers
create or replace function set_updated_at() returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- ---------------------------------------------------------------- config
create table brands (
  slug        text primary key,
  name        text not null,
  active      boolean not null default true,
  accounts    jsonb not null default '{}'::jsonb,   -- {platform: [{account_id, handle}]}
  created_at  timestamptz not null default now()
);

create table autonomy (                              -- human-controlled; agents must not write
  gate        text primary key check (gate in ('G1','G2','G3')),
  auto        boolean not null default false,
  changed_by  text,
  changed_at  timestamptz not null default now()
);
insert into autonomy (gate) values ('G1'), ('G2'), ('G3');

create table budgets (
  scope       text primary key check (scope in ('day','video')),
  cap_usd     numeric(10,2) not null check (cap_usd >= 0),
  updated_at  timestamptz not null default now()
);
insert into budgets (scope, cap_usd) values ('day', 10), ('video', 2);   -- placeholders: set real caps

-- ---------------------------------------------------------------- trends
create table trends (
  id                 uuid primary key default gen_random_uuid(),
  brand              text not null references brands(slug),
  platform           text not null check (platform in ('instagram','tiktok','youtube','facebook','x','threads','reddit','other')),
  url                text not null,
  url_hash           text not null,
  creator_handle     text,
  creator_followers  bigint,
  posted_at          timestamptz,
  discovered_at      timestamptz not null default now(),
  niche              text,
  lifecycle          text check (lifecycle in ('emerging','rising','peak','declining')),
  score              numeric,
  status             text not null default 'new' check (status in ('new','briefed','rejected')),
  fail_reason        text,
  claimed_by         text,
  lease_until        timestamptz,
  meta               jsonb not null default '{}'::jsonb,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (brand, url_hash)
);

create table trend_snapshots (
  id            uuid primary key default gen_random_uuid(),
  trend_id      uuid not null references trends(id) on delete cascade,
  captured_at   timestamptz not null default now(),
  views         bigint,
  likes         bigint,
  comments      bigint,
  shares        bigint,
  saves         bigint,
  usage_count   bigint,                              -- creators using the same audio/format
  unique (trend_id, captured_at)
);

-- ---------------------------------------------------------------- briefs
create table briefs (
  id                 uuid primary key default gen_random_uuid(),
  trend_id           uuid not null unique references trends(id) on delete cascade,
  brand              text not null references brands(slug),
  url                text not null,
  hook_text          text,
  hook_type          text check (hook_type in ('pattern_interrupt','open_loop','bold_claim','relatable_pov','tutorial_promise','contrarian','curiosity_gap','transformation','social_proof','other')),
  hook_seconds       numeric,
  visual_desc        text,
  shot_list          jsonb not null default '[]'::jsonb,
  audio_id           text,
  audio_title        text,
  audio_type         text check (audio_type in ('original','licensed','unknown')),
  caption            text,
  hashtags           text[] not null default '{}',
  keywords           text[] not null default '{}',
  format_label       text,
  why_it_works       text,
  transcript_ref     text,                           -- storage path, not the text
  originality_risk   text check (originality_risk in ('low','medium','high')),
  brand_safety       text check (brand_safety in ('ok','review','block')),
  status             text not null default 'new' check (status in ('new','scripted','needs_human')),
  fail_reason        text,
  claimed_by         text,
  lease_until        timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------- funnels
create table funnels (
  id               uuid primary key default gen_random_uuid(),
  brand            text not null references brands(slug),
  keyword          text not null,
  offer_type       text not null check (offer_type in ('lead_magnet','tripwire','product','coaching','merch','affiliate','community')),
  manychat_flow_id text,
  copy             jsonb not null default '{}'::jsonb,   -- flow spec
  destination_url  text,
  active           boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (brand, keyword)
);

-- ---------------------------------------------------------------- concepts
create table concepts (
  id                  uuid primary key default gen_random_uuid(),
  brief_id            uuid not null references briefs(id) on delete cascade,
  brand               text not null references brands(slug),
  variant             text not null check (variant in ('A','B','C')),
  title               text not null,
  hook_line           text,
  beats               jsonb not null default '[]'::jsonb,
  shot_list           jsonb not null default '[]'::jsonb,
  voiceover           text,
  on_screen_text      jsonb not null default '[]'::jsonb,
  caption             text,
  hashtags            text[] not null default '{}',
  audio_plan          jsonb not null default '{}'::jsonb,
  engagement_trigger  jsonb not null default '{}'::jsonb,
  cta_keyword         text,
  funnel_id           uuid references funnels(id),
  comfy_recipe        jsonb not null default '{}'::jsonb,   -- {workflow, params}
  compliance          jsonb not null default '{}'::jsonb,   -- last compliance-check result
  status              text not null default 'drafted' check (status in (
                        'drafted','approved','rendering','rendered','qa_passed','qa_failed',
                        'finishing','finished','approved_cut','scheduled','posted','measured',
                        'killed','needs_human')),
  fail_reason         text,
  claimed_by          text,
  lease_until         timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (brief_id, variant)
);

-- ---------------------------------------------------------------- human gates
create table gate_approvals (
  id           uuid primary key default gen_random_uuid(),
  concept_id   uuid not null references concepts(id) on delete cascade,
  gate         text not null check (gate in ('G1','G2','G3')),
  decision     text not null default 'approved' check (decision in ('approved','rejected')),
  approved_by  text not null,
  reason       text,
  created_at   timestamptz not null default now(),
  unique (concept_id, gate)
);

-- ---------------------------------------------------------------- production
create table renders (
  id               uuid primary key default gen_random_uuid(),
  concept_id       uuid not null references concepts(id) on delete cascade,
  attempt          int not null default 1,
  pass_type        text not null check (pass_type in ('draft','final')),
  backend          text not null default 'comfy_api' check (backend in ('comfy_api','runpod','comfy_cloud','local')),
  deployment       text,
  workflow         text not null,
  workflow_release text,
  params           jsonb not null default '{}'::jsonb,
  seed             bigint,
  job_id           text,
  idempotency_key  text unique,
  status           text not null default 'queued' check (status in ('queued','running','succeeded','failed','cancelled')),
  gpu_seconds      numeric,
  cost_usd         numeric(12,6),
  output_path      text,                              -- Supabase Storage path (never a signed URL)
  qa               jsonb not null default '{}'::jsonb,
  qa_pass          boolean,
  error            text,
  created_at       timestamptz not null default now(),
  finished_at      timestamptz
);

create table finished_assets (
  id                uuid primary key default gen_random_uuid(),
  concept_id        uuid not null references concepts(id) on delete cascade,
  render_id         uuid not null references renders(id),
  template          text not null,
  template_version  text,
  storage_path      text not null,
  duration_s        numeric,
  captions_path     text,
  platform_variants jsonb not null default '{}'::jsonb,   -- {platform: storage_path}
  status            text not null default 'ready' check (status in ('ready','failed')),
  fail_reason       text,
  claimed_by        text,
  lease_until       timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ---------------------------------------------------------------- distribution & measurement
create table posts (
  id                      uuid primary key default gen_random_uuid(),
  concept_id              uuid not null references concepts(id) on delete cascade,
  asset_id                uuid not null references finished_assets(id),
  platform                text not null check (platform in ('instagram','tiktok','youtube','facebook','x','threads')),
  account_id              text not null,
  blotato_submission_id   text,
  scheduled_at            timestamptz,
  posted_at               timestamptz,
  post_url                text,
  caption                 text,
  hashtags                text[] not null default '{}',
  first_comment           text,
  ai_label                boolean not null default true,
  dry_run                 boolean not null default true,
  status                  text not null default 'pending' check (status in ('pending','scheduled','posted','failed')),
  fail_reason             text,
  claimed_by              text,
  lease_until             timestamptz,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);

create table post_metrics (
  id               uuid primary key default gen_random_uuid(),
  post_id          uuid not null references posts(id) on delete cascade,
  metric_window    text not null check (metric_window in ('1h','6h','24h','72h','7d')),
  captured_at      timestamptz not null default now(),
  views            bigint,
  avg_watch_pct    numeric,
  completion_pct   numeric,
  likes            bigint,
  comments         bigint,
  shares           bigint,
  saves            bigint,
  follows          bigint,
  unique (post_id, metric_window)
);

create table leads (
  id                  uuid primary key default gen_random_uuid(),
  brand               text not null references brands(slug),
  platform            text not null,
  handle              text not null,
  funnel_id           uuid references funnels(id),
  source_post_id      uuid references posts(id),
  stage               text not null default 'new' check (stage in ('new','engaged','qualified','customer','unsubscribed')),
  tags                text[] not null default '{}',
  email               text,
  opted_in_at         timestamptz,
  last_interaction_at timestamptz,
  created_at          timestamptz not null default now(),
  unique (platform, handle, funnel_id)
);

-- ---------------------------------------------------------------- cost, memory, audit
create table ledger (
  id          uuid primary key default gen_random_uuid(),
  ts          timestamptz not null default now(),
  agent       text not null,
  kind        text not null check (kind in ('llm','gpu','api','storage')),
  usd         numeric(12,6) not null default 0,
  units       numeric,
  unit_label  text,
  ref_table   text,
  ref_id      uuid,
  note        text
);

create table learnings (
  id            uuid primary key default gen_random_uuid(),
  brand         text not null references brands(slug),
  scope         text not null check (scope in ('hook','format','voice','timing','funnel','platform','trend')),
  pattern       text not null,
  evidence_ids  uuid[] not null default '{}',
  confidence    numeric check (confidence between 0 and 1),
  status        text not null default 'hypothesis' check (status in ('hypothesis','confirmed','retired')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table events (
  id         uuid primary key default gen_random_uuid(),
  ts         timestamptz not null default now(),
  actor      text not null,
  event      text not null,
  ref_table  text,
  ref_id     uuid,
  payload    jsonb not null default '{}'::jsonb
);

-- ---------------------------------------------------------------- indexes
create index trends_status_idx          on trends (status, created_at);
create index briefs_status_idx          on briefs (status, created_at);
create index concepts_status_idx        on concepts (status, created_at);
create index finished_assets_status_idx on finished_assets (status, created_at);
create index posts_status_idx           on posts (status, scheduled_at);
create index renders_concept_idx        on renders (concept_id, created_at);
create index snapshots_trend_idx        on trend_snapshots (trend_id, captured_at);
create index ledger_ts_idx              on ledger (ts);
create index ledger_ref_idx             on ledger (ref_table, ref_id);
create index leads_funnel_idx           on leads (funnel_id, stage);

-- ---------------------------------------------------------------- updated_at triggers
create trigger trends_updated_at          before update on trends          for each row execute function set_updated_at();
create trigger briefs_updated_at          before update on briefs          for each row execute function set_updated_at();
create trigger funnels_updated_at         before update on funnels         for each row execute function set_updated_at();
create trigger concepts_updated_at        before update on concepts        for each row execute function set_updated_at();
create trigger finished_assets_updated_at before update on finished_assets for each row execute function set_updated_at();
create trigger posts_updated_at           before update on posts           for each row execute function set_updated_at();
create trigger learnings_updated_at       before update on learnings        for each row execute function set_updated_at();

-- ---------------------------------------------------------------- DB-enforced human gates
-- A concept can only enter approved / approved_cut / scheduled with a matching gate approval,
-- unless that gate has been graduated in `autonomy`. Violations raise P0001 (store maps to exit 2).
create or replace function concepts_gate_on_update() returns trigger language plpgsql as $$
declare
  needed text;
begin
  if new.status is not distinct from old.status then
    return new;
  end if;
  needed := case new.status
              when 'approved'     then 'G1'
              when 'approved_cut' then 'G2'
              when 'scheduled'    then 'G3'
              else null
            end;
  if needed is null then
    return new;
  end if;
  if (select a.auto from autonomy a where a.gate = needed) then
    return new;
  end if;
  if exists (select 1 from gate_approvals g
              where g.concept_id = new.id and g.gate = needed and g.decision = 'approved') then
    return new;
  end if;
  raise exception 'gate % approval required to move concept % to %', needed, new.id, new.status
    using errcode = 'P0001';
end $$;

create or replace function concepts_gate_on_insert() returns trigger language plpgsql as $$
begin
  if new.status <> 'drafted' then
    raise exception 'new concepts must start as drafted (got %)', new.status using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger concepts_gate_update before update of status on concepts
  for each row execute function concepts_gate_on_update();
create trigger concepts_gate_insert before insert on concepts
  for each row execute function concepts_gate_on_insert();

-- ---------------------------------------------------------------- claim / advance / fail
create or replace function claim_rows(
  p_table text, p_status text, p_agent text, p_limit int default 10, p_lease_minutes int default 30)
returns table (id uuid) language plpgsql as $$
begin
  if p_table not in ('trends','briefs','concepts','posts','finished_assets') then
    raise exception 'claim not allowed on table %', p_table using errcode = 'P0001';
  end if;
  return query execute format(
    'update %I t set claimed_by = $1, lease_until = now() + make_interval(mins => $2)
      where t.id in (
        select s.id from %I s
         where s.status = $3 and (s.lease_until is null or s.lease_until < now())
         order by s.created_at
         limit $4
         for update skip locked)
      returning t.id', p_table, p_table)
  using p_agent, p_lease_minutes, p_status, p_limit;
end $$;

create or replace function advance_row(p_table text, p_id uuid, p_agent text, p_to text)
returns uuid language plpgsql as $$
declare
  v_id uuid;
begin
  if p_table not in ('trends','briefs','concepts','posts','finished_assets') then
    raise exception 'advance not allowed on table %', p_table using errcode = 'P0001';
  end if;
  execute format(
    'update %I set status = $1, claimed_by = null, lease_until = null
      where id = $2 and claimed_by = $3 returning id', p_table)
    into v_id using p_to, p_id, p_agent;
  if v_id is null then
    raise exception 'lease lost or row not claimed by %: % %', p_agent, p_table, p_id using errcode = 'P0002';
  end if;
  return v_id;
end $$;

create or replace function fail_row(p_table text, p_id uuid, p_agent text, p_reason text, p_to text default null)
returns uuid language plpgsql as $$
declare
  v_id uuid;
  v_to text;
begin
  v_to := coalesce(p_to, case p_table
            when 'trends'          then 'rejected'
            when 'briefs'          then 'needs_human'
            when 'concepts'        then 'needs_human'
            when 'posts'           then 'failed'
            when 'finished_assets' then 'failed'
          end);
  if v_to is null then
    raise exception 'fail not allowed on table %', p_table using errcode = 'P0001';
  end if;
  execute format(
    'update %I set status = $1, fail_reason = $2, claimed_by = null, lease_until = null
      where id = $3 and claimed_by = $4 returning id', p_table)
    into v_id using v_to, p_reason, p_id, p_agent;
  if v_id is null then
    raise exception 'lease lost or row not claimed by %: % %', p_agent, p_table, p_id using errcode = 'P0002';
  end if;
  return v_id;
end $$;

-- ---------------------------------------------------------------- human review (reviewer key only; see docs/GUARDRAILS.md)
create or replace function approve_gate(p_gate text, p_ids uuid[], p_by text)
returns int language plpgsql as $$
declare
  v_id uuid;
  v_n int := 0;
  v_from text;
  v_to text;
begin
  if p_gate not in ('G1','G2','G3') then
    raise exception 'unknown gate %', p_gate using errcode = 'P0001';
  end if;
  v_from := case p_gate when 'G1' then 'drafted' when 'G2' then 'finished' else 'approved_cut' end;
  v_to   := case p_gate when 'G1' then 'approved' when 'G2' then 'approved_cut' else null end;
  foreach v_id in array p_ids loop
    if not exists (select 1 from concepts c where c.id = v_id and c.status = v_from) then
      raise exception 'concept % is not in % for gate %', v_id, v_from, p_gate using errcode = 'P0001';
    end if;
    insert into gate_approvals (concept_id, gate, decision, approved_by)
      values (v_id, p_gate, 'approved', p_by)
      on conflict (concept_id, gate) do update set decision = 'approved', approved_by = excluded.approved_by, created_at = now();
    if v_to is not null then
      update concepts set status = v_to where id = v_id;   -- G3 is applied by the publisher's own advance
    end if;
    v_n := v_n + 1;
  end loop;
  return v_n;
end $$;

create or replace function reject_gate(p_gate text, p_id uuid, p_by text, p_reason text)
returns uuid language plpgsql as $$
begin
  insert into gate_approvals (concept_id, gate, decision, approved_by, reason)
    values (p_id, p_gate, 'rejected', p_by, p_reason)
    on conflict (concept_id, gate) do update set decision = 'rejected', approved_by = excluded.approved_by,
                                                 reason = excluded.reason, created_at = now();
  update concepts set status = 'killed', fail_reason = p_reason, claimed_by = null, lease_until = null where id = p_id;
  return p_id;
end $$;

-- ---------------------------------------------------------------- budget and status
create or replace function budget_status(p_concept uuid default null)
returns table (scope text, cap_usd numeric, spent_usd numeric, remaining_usd numeric, blocked boolean)
language sql stable as $$
  with day_spend as (
    select coalesce(sum(l.usd), 0) as s from ledger l
     where l.ts >= date_trunc('day', now() at time zone 'utc') at time zone 'utc'
  ),
  video_spend as (
    select coalesce(sum(l.usd), 0) as s from ledger l
     where p_concept is not null and l.ref_table = 'concepts' and l.ref_id = p_concept
  )
  select 'day'::text, b.cap_usd, d.s, b.cap_usd - d.s, (b.cap_usd - d.s) <= 0
    from budgets b, day_spend d where b.scope = 'day'
  union all
  select 'video'::text, b.cap_usd, v.s, b.cap_usd - v.s, (b.cap_usd - v.s) <= 0
    from budgets b, video_spend v where b.scope = 'video' and p_concept is not null;
$$;

create or replace view v_status as
  select 'trends'::text as tbl, status, count(*) as n, min(created_at) as oldest from trends group by status
  union all select 'briefs',   status, count(*), min(created_at) from briefs   group by status
  union all select 'concepts', status, count(*), min(created_at) from concepts group by status
  union all select 'posts',    status, count(*), min(created_at) from posts     group by status;

create or replace view v_pending_gates as
  select 'G1'::text as gate, id, title, created_at as waiting_since from concepts where status = 'drafted'
  union all select 'G2', id, title, updated_at from concepts where status = 'finished'
  union all select 'G3', id, title, updated_at from concepts where status = 'approved_cut';

create or replace view v_stale_leases as
  select 'trends'::text as tbl, id, claimed_by, lease_until from trends where lease_until < now()
  union all select 'briefs',   id, claimed_by, lease_until from briefs   where lease_until < now()
  union all select 'concepts', id, claimed_by, lease_until from concepts where lease_until < now()
  union all select 'posts',    id, claimed_by, lease_until from posts     where lease_until < now();

-- ---------------------------------------------------------------- security
-- Supabase exposes `public` tables through its API. Enable RLS everywhere with NO policies:
-- anon/authenticated get nothing; the service role bypasses RLS. Add policies only deliberately.
alter table brands          enable row level security;
alter table autonomy        enable row level security;
alter table budgets         enable row level security;
alter table trends          enable row level security;
alter table trend_snapshots enable row level security;
alter table briefs          enable row level security;
alter table funnels         enable row level security;
alter table concepts        enable row level security;
alter table gate_approvals  enable row level security;
alter table renders         enable row level security;
alter table finished_assets enable row level security;
alter table posts           enable row level security;
alter table post_metrics    enable row level security;
alter table leads           enable row level security;
alter table ledger          enable row level security;
alter table learnings       enable row level security;
alter table events          enable row level security;

-- Recommended hardening (review, then run separately; not part of this migration):
--   create role mbm_agent nologin;  create role mbm_reviewer nologin;
--   revoke execute on function approve_gate(text, uuid[], text), reject_gate(text, uuid, text, text) from public;
--   grant  execute on function approve_gate(text, uuid[], text), reject_gate(text, uuid, text, text) to mbm_reviewer;
--   revoke insert, update, delete on gate_approvals, autonomy from mbm_agent;
-- Agents should use a key mapped to mbm_agent; only the human reviewer key may call approve_gate/reject_gate.
