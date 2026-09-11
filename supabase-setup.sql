-- ============================================================
-- 구례·하동 채집함 — Supabase 설정 스크립트
-- Supabase 대시보드 > SQL Editor 에서 이 파일 전체를 붙여넣고 실행(Run)하세요.
-- ============================================================

-- 1) 기록 테이블
create table if not exists entries (
  id uuid primary key default gen_random_uuid(),
  author_name text not null,
  occurred_at text,
  location text,
  text text,
  media jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

-- 2) Row Level Security 활성화 + 워크샵용 오픈 정책
--    (누구나 링크만 있으면 읽기/쓰기/삭제 가능 — Firebase 테스트 모드와 동일한 수준)
alter table entries enable row level security;

drop policy if exists "public can read entries" on entries;
create policy "public can read entries" on entries
  for select using (true);

drop policy if exists "public can insert entries" on entries;
create policy "public can insert entries" on entries
  for insert with check (true);

drop policy if exists "public can delete entries" on entries;
create policy "public can delete entries" on entries
  for delete using (true);

-- 3) 실시간 업데이트(다른 사람이 올린 기록이 자동으로 화면에 뜨게 함) 활성화
alter publication supabase_realtime add table entries;

-- 4) 사진/영상을 담을 Storage 버킷 생성 (공개 버킷)
insert into storage.buckets (id, name, public)
values ('entries-media', 'entries-media', true)
on conflict (id) do nothing;

-- 5) 버킷에 대한 오픈 정책 (업로드/조회/삭제 모두 허용)
drop policy if exists "public can upload media" on storage.objects;
create policy "public can upload media" on storage.objects
  for insert with check (bucket_id = 'entries-media');

drop policy if exists "public can read media" on storage.objects;
create policy "public can read media" on storage.objects
  for select using (bucket_id = 'entries-media');

drop policy if exists "public can delete media" on storage.objects;
create policy "public can delete media" on storage.objects
  for delete using (bucket_id = 'entries-media');

-- ============================================================
-- 끝. 이후 Project Settings > API 에서
--   - Project URL
--   - anon public key
-- 두 값을 복사해서 index.html의 SUPABASE_URL / SUPABASE_ANON_KEY 자리에 붙여넣으세요.
-- ============================================================


-- ============================================================
-- 추가 마이그레이션 (감흥 태그 + 좋아요 + 댓글 기능)
-- 위 스크립트를 이미 실행했다면, 아래 내용만 추가로 SQL Editor에 붙여넣고
-- 실행(Run)하면 돼요. 여러 번 실행해도 안전합니다.
-- ============================================================

-- 6) entries 테이블에 '감흥' 태그 컬럼 추가
alter table entries add column if not exists mood text;

-- 7) 좋아요 테이블
create table if not exists entry_likes (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references entries(id) on delete cascade,
  author_name text not null,
  created_at timestamptz default now(),
  unique(entry_id, author_name)
);
alter table entry_likes enable row level security;

drop policy if exists "public can read likes" on entry_likes;
create policy "public can read likes" on entry_likes
  for select using (true);

drop policy if exists "public can insert likes" on entry_likes;
create policy "public can insert likes" on entry_likes
  for insert with check (true);

drop policy if exists "public can delete likes" on entry_likes;
create policy "public can delete likes" on entry_likes
  for delete using (true);

alter publication supabase_realtime add table entry_likes;

-- 8) 댓글 테이블
create table if not exists entry_comments (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references entries(id) on delete cascade,
  author_name text not null,
  text text not null,
  created_at timestamptz default now()
);
alter table entry_comments enable row level security;

drop policy if exists "public can read comments" on entry_comments;
create policy "public can read comments" on entry_comments
  for select using (true);

drop policy if exists "public can insert comments" on entry_comments;
create policy "public can insert comments" on entry_comments
  for insert with check (true);

drop policy if exists "public can delete comments" on entry_comments;
create policy "public can delete comments" on entry_comments
  for delete using (true);

alter publication supabase_realtime add table entry_comments;

-- ============================================================
-- 끝. 이 마이그레이션을 실행한 뒤에 배포된 최신 index.html을 올리면
-- 감흥 태그 / 좋아요 / 댓글 기능이 바로 동작해요.
-- ============================================================
