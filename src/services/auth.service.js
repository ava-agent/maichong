import { getSupabase, isSupabaseConfigured } from '../lib/supabase.js'
import { store } from '../lib/store.js'
import { navigate } from '../router.js'

// 演示模式：生成稳定的用户ID（基于email哈希，保证跨会话一致）
function getDemoUserId(email) {
  const stored = localStorage.getItem('maichong_demo_user')
  if (stored) {
    try {
      const parsed = JSON.parse(stored)
      if (parsed.email === email) return parsed.id
    } catch {}
  }
  const id = crypto.randomUUID()
  localStorage.setItem('maichong_demo_user', JSON.stringify({ email, id }))
  return id
}

export async function signUp(email, password, displayName) {
  if (!isSupabaseConfigured()) {
    // 演示模式：模拟登录（使用稳定ID）
    const mockUser = { id: getDemoUserId(email), email, user_metadata: { display_name: displayName } }
    store.setState({ user: mockUser })
    navigate('/')
    return { user: mockUser, error: null }
  }

  const supabase = getSupabase()
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { display_name: displayName } }
  })

  if (!error && data.user) {
    store.setState({ user: data.user })
    navigate('/')
  }
  return { user: data?.user, error }
}

export async function signIn(email, password) {
  if (!isSupabaseConfigured()) {
    const mockUser = { id: getDemoUserId(email), email, user_metadata: { display_name: email.split('@')[0] } }
    store.setState({ user: mockUser })
    navigate('/')
    return { user: mockUser, error: null }
  }

  const supabase = getSupabase()
  const { data, error } = await supabase.auth.signInWithPassword({ email, password })

  if (!error && data.user) {
    store.setState({ user: data.user })
    navigate('/')
  }
  return { user: data?.user, error }
}

export async function signOut() {
  if (isSupabaseConfigured()) {
    await getSupabase().auth.signOut()
  }
  store.setState({ user: null, timelines: [], currentTimeline: null, events: [], members: [] })
  navigate('/auth')
}

export function getCurrentUser() {
  return store.getState().user
}

export function getUserDisplayName(user) {
  if (!user) return '未知'
  return user.user_metadata?.display_name || user.email?.split('@')[0] || '用户'
}
