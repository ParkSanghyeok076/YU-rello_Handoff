# YU-rello

팀 업무를 보드 · 리스트 · 카드로 관리하는 칸반 도구입니다 (Trello와 비슷한 사내용 웹앱).

- 프론트엔드: Next.js 16 · React 19 · Tailwind CSS 4
- 백엔드: Supabase (Postgres DB · 로그인 · 실시간 동기화)
- 배포: Vercel (GitHub `main` 브랜치에 push하면 자동 배포)

**처음이라면 [인수인계.md](./인수인계.md)부터 읽으세요.** 설치, 구축, 유지보수, 사용법이 모두 들어 있습니다.

## 빠른 시작 (이미 구축을 마친 경우)

```bash
npm install
npm run dev
```

브라우저에서 http://localhost:3000 을 엽니다. 실행 전에 `.env.example`을 참고해 `.env.local`을 만들어야 합니다.

## 폴더

| 경로 | 내용 |
|---|---|
| `app/` | 화면(페이지)과 로그인 콜백 |
| `components/` | 보드·리스트·카드 등 화면 부품 |
| `hooks/`, `lib/` | 실시간 구독, Supabase 연결, 알림 |
| `supabase/` | DB 구축용 SQL (스키마 · 관리자 지정 · 보드 데이터) |
| `AGENTS.md` | Codex(AI 코딩 도구)가 읽는 프로젝트 설명서 |
