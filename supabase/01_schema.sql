-- =====================================================================
-- YU-rello 데이터베이스 스키마 (테이블 13개 + 권한(RLS) + 회원가입 트리거 + 실시간)
-- 사용법: Supabase 대시보드 > SQL Editor > New query 에 전체 붙여넣기 > Run
-- 새 프로젝트에서 "딱 한 번" 실행합니다. 데이터는 들어있지 않습니다.
-- =====================================================================

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  BEGIN
    INSERT INTO public.profiles (id, email, name)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
  END;
  $$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."board_members" (
    "board_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL
);

ALTER TABLE "public"."board_members" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."boards" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" "text" NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE "public"."boards" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."card_labels" (
    "card_id" "uuid" NOT NULL,
    "label_id" "uuid" NOT NULL
);

ALTER TABLE "public"."card_labels" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."card_members" (
    "card_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL
);

ALTER TABLE "public"."card_members" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."cards" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "list_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "due_date" timestamp with time zone,
    "position" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "start_date" "date",
    "archived_at" timestamp with time zone
);

ALTER TABLE "public"."cards" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."checklist_items" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" "text" NOT NULL,
    "due_date" timestamp with time zone,
    "completed" boolean DEFAULT false,
    "position" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "checklist_id" "uuid" NOT NULL
);

ALTER TABLE "public"."checklist_items" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."checklists" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "card_id" "uuid",
    "title" "text" DEFAULT '체크리스트'::"text" NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE "public"."checklists" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "card_id" "uuid",
    "user_id" "uuid",
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE "public"."comments" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."labels" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "board_id" "uuid",
    "name" "text" NOT NULL,
    "color" "text" NOT NULL
);

ALTER TABLE "public"."labels" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."list_members" (
    "list_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL
);

ALTER TABLE "public"."list_members" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."lists" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "board_id" "uuid",
    "title" "text" NOT NULL,
    "position" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "archived_at" timestamp with time zone
);

ALTER TABLE "public"."lists" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "type" "text" NOT NULL,
    "card_id" "uuid",
    "message" "text" NOT NULL,
    "read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);

ALTER TABLE "public"."notifications" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "name" "text" NOT NULL,
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_admin" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."profiles" OWNER TO "postgres";

ALTER TABLE ONLY "public"."board_members"
    ADD CONSTRAINT "board_members_pkey" PRIMARY KEY ("board_id", "user_id");

ALTER TABLE ONLY "public"."boards"
    ADD CONSTRAINT "boards_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."card_labels"
    ADD CONSTRAINT "card_labels_pkey" PRIMARY KEY ("card_id", "label_id");

ALTER TABLE ONLY "public"."card_members"
    ADD CONSTRAINT "card_members_pkey" PRIMARY KEY ("card_id", "user_id");

ALTER TABLE ONLY "public"."cards"
    ADD CONSTRAINT "cards_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."checklist_items"
    ADD CONSTRAINT "checklist_items_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."checklists"
    ADD CONSTRAINT "checklists_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."labels"
    ADD CONSTRAINT "labels_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."list_members"
    ADD CONSTRAINT "list_members_pkey" PRIMARY KEY ("list_id", "user_id");

ALTER TABLE ONLY "public"."lists"
    ADD CONSTRAINT "lists_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."board_members"
    ADD CONSTRAINT "board_members_board_id_fkey" FOREIGN KEY ("board_id") REFERENCES "public"."boards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."board_members"
    ADD CONSTRAINT "board_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."boards"
    ADD CONSTRAINT "boards_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."card_labels"
    ADD CONSTRAINT "card_labels_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "public"."cards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."card_labels"
    ADD CONSTRAINT "card_labels_label_id_fkey" FOREIGN KEY ("label_id") REFERENCES "public"."labels"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."card_members"
    ADD CONSTRAINT "card_members_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "public"."cards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."card_members"
    ADD CONSTRAINT "card_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."cards"
    ADD CONSTRAINT "cards_list_id_fkey" FOREIGN KEY ("list_id") REFERENCES "public"."lists"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."checklist_items"
    ADD CONSTRAINT "checklist_items_checklist_id_fkey" FOREIGN KEY ("checklist_id") REFERENCES "public"."checklists"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."checklists"
    ADD CONSTRAINT "checklists_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "public"."cards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "public"."cards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."labels"
    ADD CONSTRAINT "labels_board_id_fkey" FOREIGN KEY ("board_id") REFERENCES "public"."boards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."list_members"
    ADD CONSTRAINT "list_members_list_id_fkey" FOREIGN KEY ("list_id") REFERENCES "public"."lists"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."list_members"
    ADD CONSTRAINT "list_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."lists"
    ADD CONSTRAINT "lists_board_id_fkey" FOREIGN KEY ("board_id") REFERENCES "public"."boards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_card_id_fkey" FOREIGN KEY ("card_id") REFERENCES "public"."cards"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

CREATE POLICY "Allow all for authenticated users" ON "public"."checklists" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Authenticated users can create boards" ON "public"."boards" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can create cards" ON "public"."cards" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can create lists" ON "public"."lists" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can delete boards" ON "public"."boards" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete card_labels" ON "public"."card_labels" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete card_members" ON "public"."card_members" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete cards" ON "public"."cards" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete checklist_items" ON "public"."checklist_items" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete comments" ON "public"."comments" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete labels" ON "public"."labels" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete lists" ON "public"."lists" FOR DELETE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can delete notifications" ON "public"."notifications" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));

CREATE POLICY "Authenticated users can insert card_labels" ON "public"."card_labels" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can insert card_members" ON "public"."card_members" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can insert checklist_items" ON "public"."checklist_items" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can insert comments" ON "public"."comments" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can insert labels" ON "public"."labels" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can insert notifications" ON "public"."notifications" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Authenticated users can update boards" ON "public"."boards" FOR UPDATE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can update cards" ON "public"."cards" FOR UPDATE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can update checklist_items" ON "public"."checklist_items" FOR UPDATE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can update comments" ON "public"."comments" FOR UPDATE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can update labels" ON "public"."labels" FOR UPDATE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can update lists" ON "public"."lists" FOR UPDATE TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can update notifications" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id"));

CREATE POLICY "Authenticated users can view all cards" ON "public"."cards" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view all lists" ON "public"."lists" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view card_labels" ON "public"."card_labels" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view card_members" ON "public"."card_members" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view checklist_items" ON "public"."checklist_items" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view comments" ON "public"."comments" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view labels" ON "public"."labels" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Authenticated users can view notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));

CREATE POLICY "Public profiles are viewable by everyone" ON "public"."profiles" FOR SELECT USING (true);

CREATE POLICY "Users can see boards they created" ON "public"."boards" FOR SELECT USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));

ALTER TABLE "public"."board_members" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "board_members deletable by creator or admin" ON "public"."board_members" FOR DELETE USING (((EXISTS ( SELECT 1
   FROM "public"."boards"
  WHERE (("boards"."id" = "board_members"."board_id") AND ("boards"."created_by" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_admin" = true))))));

CREATE POLICY "board_members insertable by creator or admin" ON "public"."board_members" FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."boards"
  WHERE (("boards"."id" = "board_members"."board_id") AND ("boards"."created_by" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_admin" = true))))));

CREATE POLICY "board_members viewable by members" ON "public"."board_members" FOR SELECT USING (("user_id" = "auth"."uid"()));

ALTER TABLE "public"."boards" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "boards deletable by creator or admin" ON "public"."boards" FOR DELETE USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_admin" = true))))));

CREATE POLICY "boards visible to members only" ON "public"."boards" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."board_members"
  WHERE (("board_members"."board_id" = "boards"."id") AND ("board_members"."user_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_admin" = true))))));

ALTER TABLE "public"."card_labels" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."card_members" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."cards" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cards deletable by board creator or admin" ON "public"."cards" FOR DELETE USING (((EXISTS ( SELECT 1
   FROM ("public"."lists" "l"
     JOIN "public"."boards" "b" ON (("b"."id" = "l"."board_id")))
  WHERE (("l"."id" = "cards"."list_id") AND ("b"."created_by" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_admin" = true))))));

ALTER TABLE "public"."checklist_items" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."checklists" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."labels" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."list_members" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "list_members are viewable by everyone" ON "public"."list_members" FOR SELECT USING (true);

CREATE POLICY "list_members can be managed by authenticated users" ON "public"."list_members" USING (("auth"."uid"() IS NOT NULL));

ALTER TABLE "public"."lists" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "lists deletable by board creator or admin" ON "public"."lists" FOR DELETE USING (((EXISTS ( SELECT 1
   FROM "public"."boards"
  WHERE (("boards"."id" = "lists"."board_id") AND ("boards"."created_by" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."is_admin" = true))))));

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON TABLE "public"."board_members" TO "anon";
GRANT ALL ON TABLE "public"."board_members" TO "authenticated";
GRANT ALL ON TABLE "public"."board_members" TO "service_role";

GRANT ALL ON TABLE "public"."boards" TO "anon";
GRANT ALL ON TABLE "public"."boards" TO "authenticated";
GRANT ALL ON TABLE "public"."boards" TO "service_role";

GRANT ALL ON TABLE "public"."card_labels" TO "anon";
GRANT ALL ON TABLE "public"."card_labels" TO "authenticated";
GRANT ALL ON TABLE "public"."card_labels" TO "service_role";

GRANT ALL ON TABLE "public"."card_members" TO "anon";
GRANT ALL ON TABLE "public"."card_members" TO "authenticated";
GRANT ALL ON TABLE "public"."card_members" TO "service_role";

GRANT ALL ON TABLE "public"."cards" TO "anon";
GRANT ALL ON TABLE "public"."cards" TO "authenticated";
GRANT ALL ON TABLE "public"."cards" TO "service_role";

GRANT ALL ON TABLE "public"."checklist_items" TO "anon";
GRANT ALL ON TABLE "public"."checklist_items" TO "authenticated";
GRANT ALL ON TABLE "public"."checklist_items" TO "service_role";

GRANT ALL ON TABLE "public"."checklists" TO "anon";
GRANT ALL ON TABLE "public"."checklists" TO "authenticated";
GRANT ALL ON TABLE "public"."checklists" TO "service_role";

GRANT ALL ON TABLE "public"."comments" TO "anon";
GRANT ALL ON TABLE "public"."comments" TO "authenticated";
GRANT ALL ON TABLE "public"."comments" TO "service_role";

GRANT ALL ON TABLE "public"."labels" TO "anon";
GRANT ALL ON TABLE "public"."labels" TO "authenticated";
GRANT ALL ON TABLE "public"."labels" TO "service_role";

GRANT ALL ON TABLE "public"."list_members" TO "anon";
GRANT ALL ON TABLE "public"."list_members" TO "authenticated";
GRANT ALL ON TABLE "public"."list_members" TO "service_role";

GRANT ALL ON TABLE "public"."lists" TO "anon";
GRANT ALL ON TABLE "public"."lists" TO "authenticated";
GRANT ALL ON TABLE "public"."lists" TO "service_role";

GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";

-- 회원가입하면 profiles 행을 자동으로 만드는 트리거
DROP TRIGGER IF EXISTS "on_auth_user_created" ON "auth"."users";
CREATE TRIGGER "on_auth_user_created"
  AFTER INSERT ON "auth"."users"
  FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();

-- 실시간 동기화(다른 사람이 수정하면 화면 자동 갱신)에 쓰는 테이블 등록
ALTER PUBLICATION "supabase_realtime" ADD TABLE
  "public"."lists", "public"."cards", "public"."checklists", "public"."checklist_items", "public"."comments", "public"."labels", "public"."card_labels", "public"."card_members", "public"."list_members", "public"."board_members", "public"."notifications";
