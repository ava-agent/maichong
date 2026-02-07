-- ============================================
-- 脉冲 (Mài Chōng) - Supabase Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE (extends Supabase auth.users)
-- ============================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    nickname TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TIMELINES TABLE
-- ============================================
CREATE TABLE public.timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    color TEXT DEFAULT '#6366f1',
    icon TEXT DEFAULT 'timeline',
    owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TIMELINE MEMBERS TABLE
-- ============================================
CREATE TABLE public.timeline_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeline_id UUID REFERENCES public.timelines(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(timeline_id, user_id)
);

-- ============================================
-- EVENTS TABLE
-- ============================================
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeline_id UUID REFERENCES public.timelines(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    location TEXT,
    is_all_day BOOLEAN DEFAULT FALSE,
    color TEXT DEFAULT '#6366f1',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT end_time_after_start_time CHECK (end_time > start_time)
);

-- ============================================
-- INVITATIONS TABLE
-- ============================================
CREATE TABLE public.invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeline_id UUID REFERENCES public.timelines(id) ON DELETE CASCADE,
    inviter_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    invitee_email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_timelines_owner_id ON public.timelines(owner_id);
CREATE INDEX idx_timeline_members_timeline_id ON public.timeline_members(timeline_id);
CREATE INDEX idx_timeline_members_user_id ON public.timeline_members(user_id);
CREATE INDEX idx_events_timeline_id ON public.events(timeline_id);
CREATE INDEX idx_events_creator_id ON public.events(creator_id);
CREATE INDEX idx_events_start_time ON public.events(start_time);
CREATE INDEX idx_invitations_invitee_email ON public.invitations(invitee_email);

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_timelines_updated_at
    BEFORE UPDATE ON public.timelines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at
    BEFORE UPDATE ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Auto-create timeline member when timeline is created
CREATE OR REPLACE FUNCTION create_timeline_owner_member()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.timeline_members (timeline_id, user_id, role)
    VALUES (NEW.id, NEW.owner_id, 'owner');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_owner_member
    AFTER INSERT ON public.timelines
    FOR EACH ROW
    EXECUTE FUNCTION create_timeline_owner_member();

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timeline_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

-- USERS POLICIES
CREATE POLICY "Users can view their own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can view profiles of people in shared timelines"
    ON public.users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_members.user_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM public.timeline_members tm2
                WHERE tm2.timeline_id = timeline_members.timeline_id
                AND tm2.user_id = users.id
            )
        )
    );

-- TIMELINES POLICIES
CREATE POLICY "Users can view timelines they are members of"
    ON public.timelines FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = timelines.id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create timelines"
    ON public.timelines FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Timeline owners can update timelines"
    ON public.timelines FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = timelines.id
            AND user_id = auth.uid()
            AND role IN ('owner', 'admin')
        )
    );

CREATE POLICY "Timeline owners can delete timelines"
    ON public.timelines FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = timelines.id
            AND user_id = auth.uid()
            AND role = 'owner'
        )
    );

-- TIMELINE MEMBERS POLICIES
CREATE POLICY "Users can view members of their timelines"
    ON public.timeline_members FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members tm2
            WHERE tm2.timeline_id = timeline_members.timeline_id
            AND tm2.user_id = auth.uid()
        )
    );

CREATE POLICY "Owners and admins can add members"
    ON public.timeline_members FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = timeline_members.timeline_id
            AND user_id = auth.uid()
            AND role IN ('owner', 'admin')
        )
    );

CREATE POLICY "Owners can remove members"
    ON public.timeline_members FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members tm
            WHERE tm.timeline_id = timeline_members.timeline_id
            AND tm.user_id = auth.uid()
            AND tm.role = 'owner'
        )
        AND timeline_members.role != 'owner'
    );

CREATE POLICY "Owners can update member roles"
    ON public.timeline_members FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members tm
            WHERE tm.timeline_id = timeline_members.timeline_id
            AND tm.user_id = auth.uid()
            AND tm.role = 'owner'
        )
    );

-- EVENTS POLICIES
CREATE POLICY "Users can view events in their timelines"
    ON public.events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = events.timeline_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Timeline members can create events"
    ON public.events FOR INSERT
    WITH CHECK (
        auth.uid() = creator_id
        AND EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = events.timeline_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Event creators can update events"
    ON public.events FOR UPDATE
    USING (
        creator_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = events.timeline_id
            AND user_id = auth.uid()
            AND role IN ('owner', 'admin')
        )
    );

CREATE POLICY "Event creators can delete events"
    ON public.events FOR DELETE
    USING (
        creator_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = events.timeline_id
            AND user_id = auth.uid()
            AND role IN ('owner', 'admin')
        )
    );

-- INVITATIONS POLICIES
CREATE POLICY "Users can view invitations sent to them"
    ON public.invitations FOR SELECT
    USING (
        invitee_email = (SELECT email FROM public.users WHERE id = auth.uid())
        OR inviter_id = auth.uid()
    );

CREATE POLICY "Timeline members can create invitations"
    ON public.invitations FOR INSERT
    WITH CHECK (
        auth.uid() = inviter_id
        AND EXISTS (
            SELECT 1 FROM public.timeline_members
            WHERE timeline_id = invitations.timeline_id
            AND user_id = auth.uid()
            AND role IN ('owner', 'admin')
        )
    );

CREATE POLICY "Invitees can update invitation status"
    ON public.invitations FOR UPDATE
    USING (
        invitee_email = (SELECT email FROM public.users WHERE id = auth.uid())
    );

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

CREATE OR REPLACE VIEW user_timelines AS
SELECT
    t.*,
    tm.role as user_role,
    (SELECT COUNT(*) FROM public.timeline_members WHERE timeline_id = t.id) as member_count
FROM public.timelines t
JOIN public.timeline_members tm ON tm.timeline_id = t.id
WHERE tm.user_id = auth.uid();

CREATE OR REPLACE VIEW timeline_events AS
SELECT
    e.*,
    u.nickname as creator_nickname,
    u.avatar_url as creator_avatar
FROM public.events e
LEFT JOIN public.users u ON u.id = e.creator_id
WHERE EXISTS (
    SELECT 1 FROM public.timeline_members
    WHERE timeline_id = e.timeline_id
    AND user_id = auth.uid()
);
