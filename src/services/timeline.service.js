import { getSupabase, isSupabaseConfigured } from '../lib/supabase.js'
import { store } from '../lib/store.js'
import { navigate } from '../router.js'
import { showToast } from '../components/toast.js'

// 本地存储 key
const LOCAL_KEY = 'maichong_timelines'

function getLocalTimelines() {
  try {
    return JSON.parse(localStorage.getItem(LOCAL_KEY) || '[]')
  } catch (e) {
    console.warn('Failed to parse local timelines:', e)
    return []
  }
}

function saveLocalTimelines(timelines) {
  localStorage.setItem(LOCAL_KEY, JSON.stringify(timelines))
}

export async function createTimeline(title, description = '') {
  const user = store.getState().user

  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('timelines')
      .insert({ title, description, owner_id: user.id })
      .select()
      .single()

    if (error) {
      showToast('创建失败：' + error.message, 'error')
      return null
    }

    // 同时添加为 owner 成员
    await supabase.from('timeline_members').insert({
      timeline_id: data.id,
      user_id: user.id,
      role: 'owner'
    })

    const timelines = [...store.getState().timelines, data]
    store.setState({ timelines })
    return data
  }

  // 本地模式
  const timeline = {
    id: crypto.randomUUID(),
    title,
    description,
    owner_id: user.id,
    invite_code: Math.random().toString(36).slice(2, 14),
    color: '#4C6EF5',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }
  const timelines = [...getLocalTimelines(), timeline]
  saveLocalTimelines(timelines)
  store.setState({ timelines })
  return timeline
}

export async function listMyTimelines() {
  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('timelines')
      .select('*, timeline_members(count)')
      .order('updated_at', { ascending: false })

    if (error) {
      showToast('加载时间线失败', 'error')
      return []
    }
    store.setState({ timelines: data })
    return data
  }

  const timelines = getLocalTimelines()
  store.setState({ timelines })
  return timelines
}

export async function getTimeline(id) {
  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('timelines')
      .select('*')
      .eq('id', id)
      .single()

    if (error) return null
    store.setState({ currentTimeline: data })
    return data
  }

  const timelines = getLocalTimelines()
  const timeline = timelines.find(t => t.id === id)
  store.setState({ currentTimeline: timeline || null })
  return timeline
}

export async function deleteTimeline(id) {
  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { error } = await supabase.from('timelines').delete().eq('id', id)
    if (error) {
      showToast('删除失败', 'error')
      return false
    }
  } else {
    const timelines = getLocalTimelines().filter(t => t.id !== id)
    saveLocalTimelines(timelines)
  }

  store.setState({ timelines: store.getState().timelines.filter(t => t.id !== id) })
  return true
}

export async function getMembers(timelineId) {
  if (!isSupabaseConfigured()) {
    const user = store.getState().user
    const members = [{ id: crypto.randomUUID(), user_id: user.id, role: 'owner', profile: { display_name: user.user_metadata?.display_name || '我' } }]
    store.setState({ members })
    return members
  }

  const supabase = getSupabase()
  const { data, error } = await supabase
    .from('timeline_members')
    .select('*, profiles(*)')
    .eq('timeline_id', timelineId)

  if (error) return []
  const members = data.map(m => ({ ...m, profile: m.profiles }))
  store.setState({ members })
  return members
}

export function generateInviteLink(timelineId) {
  // 优先根据 timelineId 查找，回退到 currentTimeline
  const state = store.getState()
  const timeline = timelineId
    ? state.timelines.find(t => t.id === timelineId) || state.currentTimeline
    : state.currentTimeline
  if (!timeline) return ''
  const base = window.location.origin + window.location.pathname
  return `${base}#/join/${timeline.invite_code}`
}

export async function handleJoinInvite(code) {
  if (!isSupabaseConfigured()) {
    showToast('演示模式不支持邀请功能', 'warning')
    navigate('/')
    return
  }

  const user = store.getState().user
  if (!user) {
    // 存储待加入的邀请码，登录后处理
    sessionStorage.setItem('pending_invite', code)
    navigate('/auth')
    return
  }

  const supabase = getSupabase()
  // 查找时间线
  const { data: timeline, error: findError } = await supabase
    .from('timelines')
    .select('id')
    .eq('invite_code', code)
    .single()

  if (findError || !timeline) {
    showToast('邀请链接无效', 'error')
    navigate('/')
    return
  }

  // 加入成员
  const { error: joinError } = await supabase
    .from('timeline_members')
    .insert({ timeline_id: timeline.id, user_id: user.id, role: 'member' })

  if (joinError && !joinError.message.includes('duplicate')) {
    showToast('加入失败：' + joinError.message, 'error')
    navigate('/')
    return
  }

  showToast('成功加入时间线！', 'success')
  navigate('/timeline/' + timeline.id)
}
