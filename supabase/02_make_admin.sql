-- =====================================================================
-- 내 계정을 관리자로 지정
-- 실행 전: 배포한 YU-rello 사이트에서 회원가입을 먼저 마치세요.
-- 사용법: 아래 이메일을 "내가 가입한 이메일"로 바꾼 뒤 SQL Editor 에서 Run
-- =====================================================================

UPDATE public.profiles
SET is_admin = true
WHERE email = '여기에-내-이메일@회사.com';

-- 확인: is_admin 이 true 로 나오면 성공
SELECT email, name, is_admin FROM public.profiles WHERE is_admin;
