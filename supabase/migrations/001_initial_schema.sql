-- ============================================
-- 脉冲 (Maichong) 数据库初始化脚本
-- 在 Supabase SQL Editor 中执行
-- ============================================

-- 1. profiles 用户资料
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 自动创建 profile 触发器
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 2. timelines 共享时间线
CREATE TABLE timelines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  invite_code TEXT UNIQUE DEFAULT encode(gen_random_bytes(6), 'hex'),
  color TEXT DEFAULT '#4F46E5',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_timelines_owner ON timelines(owner_id);
CREATE INDEX idx_timelines_invite ON timelines(invite_code);

-- 3. timeline_members 成员关系
CREATE TABLE timeline_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timeline_id UUID NOT NULL REFERENCES timelines(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'editor', 'member')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(timeline_id, user_id)
);

CREATE INDEX idx_members_timeline ON timeline_members(timeline_id);
CREATE INDEX idx_members_user ON timeline_members(user_id);

-- 4. events 脉冲事件
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timeline_id UUID NOT NULL REFERENCES timelines(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  event_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  is_all_day BOOLEAN NOT NULL DEFAULT false,
  status TEXT NOT NULL DEFAULT 'confirmed'
    CHECK (status IN ('confirmed', 'tentative', 'proposal', 'cancelled')),
  created_by UUID NOT NULL REFERENCES profiles(id),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_events_timeline ON events(timeline_id);
CREATE INDEX idx_events_date ON events(timeline_id, event_date);

-- 5. chat_messages AI 对话历史
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timeline_id UUID NOT NULL REFERENCES timelines(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id),
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_messages_timeline ON chat_messages(timeline_id, created_at);

-- ============================================
-- RLS 策略
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE timelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- SECURITY DEFINER 函数：绕过 RLS 获取用户所属时间线 ID，避免循环引用
CREATE OR REPLACE FUNCTION get_my_timeline_ids()
RETURNS SETOF UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT timeline_id FROM timeline_members WHERE user_id = auth.uid()
$$;

-- profiles
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- timelines
CREATE POLICY "timelines_select" ON timelines FOR SELECT TO authenticated
  USING (owner_id = auth.uid() OR id IN (SELECT get_my_timeline_ids()));
CREATE POLICY "timelines_insert" ON timelines FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());
CREATE POLICY "timelines_update" ON timelines FOR UPDATE TO authenticated
  USING (owner_id = auth.uid());
CREATE POLICY "timelines_delete" ON timelines FOR DELETE TO authenticated
  USING (owner_id = auth.uid());

-- timeline_members
CREATE POLICY "members_select" ON timeline_members FOR SELECT TO authenticated
  USING (timeline_id IN (SELECT get_my_timeline_ids()));
CREATE POLICY "members_insert" ON timeline_members FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR timeline_id IN (SELECT id FROM timelines WHERE owner_id = auth.uid()));
CREATE POLICY "members_delete" ON timeline_members FOR DELETE TO authenticated
  USING (user_id = auth.uid() OR timeline_id IN (SELECT id FROM timelines WHERE owner_id = auth.uid()));

-- events
CREATE POLICY "events_select" ON events FOR SELECT TO authenticated
  USING (timeline_id IN (SELECT get_my_timeline_ids()));
CREATE POLICY "events_insert" ON events FOR INSERT TO authenticated
  WITH CHECK (created_by = auth.uid() AND timeline_id IN (SELECT get_my_timeline_ids()));
CREATE POLICY "events_update" ON events FOR UPDATE TO authenticated
  USING (timeline_id IN (SELECT get_my_timeline_ids()));
CREATE POLICY "events_delete" ON events FOR DELETE TO authenticated
  USING (created_by = auth.uid() OR timeline_id IN (SELECT id FROM timelines WHERE owner_id = auth.uid()));

-- chat_messages
CREATE POLICY "chat_select" ON chat_messages FOR SELECT TO authenticated
  USING (timeline_id IN (SELECT get_my_timeline_ids()));
CREATE POLICY "chat_insert" ON chat_messages FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() AND timeline_id IN (SELECT get_my_timeline_ids()));

-- ============================================
-- Realtime 发布
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE events;
ALTER PUBLICATION supabase_realtime ADD TABLE timeline_members;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
