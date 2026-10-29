# AGENTS.md — YU-rello 작업 지침 (Codex용)

이 파일은 Codex가 작업을 시작할 때마다 읽는 프로젝트 설명서입니다. 사람이 읽어도 됩니다.
규칙이나 구조가 바뀌면 이 파일도 함께 고치세요.

## 대화 규칙
- 사용자는 개발자가 아닙니다. 답변과 설명은 **한국어**로, 전문 용어는 짧게 풀어서 씁니다.
- 수정하기 전에 무엇을 어떤 파일에서 바꿀지 먼저 짧게 설명합니다.
- 요청 범위 밖의 파일은 고치지 않습니다. 대규모 리팩터링은 먼저 물어봅니다.

## 프로젝트 개요
- 사내 칸반 보드 웹앱 (보드 → 리스트 → 카드 → 체크리스트).
- Next.js 16 App Router + React 19 + TypeScript + Tailwind CSS 4.
- 백엔드 서버 코드는 없습니다. 브라우저/서버 컴포넌트가 Supabase(Postgres + Auth + Realtime)에 직접 접속하고, 권한은 DB의 RLS 정책으로 막습니다.
- 배포: Vercel. `main` 브랜치에 push하면 자동으로 프로덕션 배포됩니다.

## 명령어
- 의존성 설치: `npm install`
- 개발 서버: `npm run dev` → http://localhost:3000
- 빌드 확인: `npm run build` (push 전에 반드시 통과해야 함. Vercel도 같은 빌드를 돌림)
- 검사: `npm run lint` — 기존 코드에 `no-explicit-any` 등 오류가 이미 많이 남아 있어 전체 통과는 기준이 아닙니다. 이번에 고친 파일에서 새 오류를 늘리지 않는 것이 기준입니다.
- 테스트 코드는 없습니다. 변경 후 build 통과 + 브라우저에서 직접 확인합니다.

## 폴더 구조
- `app/` — 페이지. `login`, `signup`, `dashboard`(보드 목록), `board/[id]`(보드 화면), `board/new`, `auth/callback`(이메일 인증 후 돌아오는 곳)
- `components/` — 화면 부품. 주요 파일:
  - `BoardView.tsx` 보드 전체(리스트 가로 배치, 드래그, 패닝), `List.tsx`, `Card.tsx`
  - `CardModal.tsx` 카드 상세 창, `ChecklistSection.tsx`/`ChecklistItem.tsx`, `CommentsSection.tsx`, `LabelsSection.tsx`, `MembersSection.tsx`
  - `Toolbar.tsx` 보드뷰/달력뷰 전환·할 일 알림(상위 10개, 기한 초과 우선)·멤버 필터·주간 리포트·아카이빙 버튼
  - `CalendarView.tsx`(FullCalendar), `WeeklyReportModal.tsx`, `ArchivePanel.tsx`, `NotificationBell.tsx`, `BoardMemberManager.tsx`
- `hooks/useRealtimeSubscription.ts` — 테이블 변경을 실시간 구독해 화면 갱신
- `lib/supabase/client.ts`(브라우저용, DB 타입 정의 포함), `lib/supabase/server.ts`(서버용), `lib/notifications.ts`
- `middleware.ts` — 매 요청마다 로그인 세션 갱신
- `supabase/` — DB SQL. `01_schema.sql`(전체 구조), `02_make_admin.sql`, `03_seed_board_2026_edu.sql`(초기 데이터, 다시 실행 금지)

## 데이터베이스
- 테이블: `profiles`(사용자, `is_admin`), `boards`, `board_members`, `lists`, `list_members`, `cards`, `card_members`, `labels`, `card_labels`, `checklists`, `checklist_items`, `comments`, `notifications`
- 관계: boards 1—N lists 1—N cards 1—N checklists 1—N checklist_items. cards 1—N comments.
- `boards` 테이블은 `board_members`에 있는 사람과 관리자(`profiles.is_admin = true`)만 볼 수 있습니다(RLS).
- 주의: `lists`, `cards`, `checklists` 등에는 로그인 사용자 전체를 허용하는 `USING (true)` 정책이 함께 있어, 실제 보호는 보드 목록 수준입니다. 정책을 강화할 때는 이 정책들을 함께 정리해야 합니다.
- 리스트·카드는 `archived_at`이 있으면 아카이빙된 상태(화면에서 숨김).
- 회원가입 시 `on_auth_user_created` 트리거가 `profiles` 행을 자동 생성합니다.

### DB 변경 규칙
- 컬럼/테이블/정책을 바꿀 때는 코드만 고치지 말고 **SQL도 함께** 만듭니다.
- 새 SQL은 `supabase/migrations/YYYYMMDD_설명.sql`로 저장하고, 사용자에게 "Supabase SQL Editor에서 실행하세요"라고 안내합니다. Codex가 운영 DB에 직접 접속하지 않습니다.
- `lib/supabase/client.ts`의 타입 정의도 같이 맞춥니다.
- 데이터를 지우는 SQL(DELETE, DROP, TRUNCATE)은 반드시 사용자에게 먼저 확인받습니다.

## 코드 스타일
- 기존 파일의 패턴을 따릅니다: 함수형 컴포넌트, `'use client'` 표시, Tailwind 클래스, Supabase 호출은 컴포넌트 안에서 `createClient()`.
- 색상: 배경 `#0d1117`, 리스트 `#161b22`, 포인트 navy 계열. 새 UI도 다크 테마에 맞춥니다.
- 화면 문구는 한국어.

## 절대 하지 말 것
- `.env.local`, API 키, secret key, 비밀번호를 코드·커밋·로그에 넣지 않습니다.
- `NEXT_PUBLIC_` 변수에 Supabase **secret/service_role** 키를 넣지 않습니다 (브라우저에 노출됨).
- RLS를 끄거나 정책을 `true`로 넓히는 변경은 사용자 확인 없이 하지 않습니다.
- `git push --force`, 히스토리 수정, `main` 브랜치 삭제 금지.
