import { getSupabase, isSupabaseConfigured } from '../lib/supabase.js'
import { store } from '../lib/store.js'
import { showToast } from '../components/toast.js'

const LOCAL_EVENTS_KEY = 'maichong_events'

function getLocalEvents(timelineId) {
  try {
    const all = JSON.parse(localStorage.getItem(LOCAL_EVENTS_KEY) || '{}')
    return all[timelineId] || []
  } catch (e) {
    console.warn('Failed to parse local events:', e)
    return []
  }
}

function saveLocalEvents(timelineId, events) {
  try {
    const all = JSON.parse(localStorage.getItem(LOCAL_EVENTS_KEY) || '{}')
    all[timelineId] = events
    localStorage.setItem(LOCAL_EVENTS_KEY, JSON.stringify(all))
  } catch (e) {
    console.warn('Failed to save local events:', e)
  }
}

export async function listEvents(timelineId) {
  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('events')
      .select('*, profiles:created_by(display_name)')
      .eq('timeline_id', timelineId)
      .order('event_date', { ascending: true })
      .order('sort_order', { ascending: true })
      .order('start_time', { ascending: true, nullsFirst: false })

    if (error) {
      showToast('加载事件失败', 'error')
      return []
    }
    store.setState({ events: data })
    return data
  }

  const events = getLocalEvents(timelineId)
  store.setState({ events })
  return events
}

export async function createEvent(timelineId, eventData) {
  const user = store.getState().user
  const newEvent = {
    id: crypto.randomUUID(),
    timeline_id: timelineId,
    created_by: user.id,
    status: 'confirmed',
    sort_order: store.getState().events.length,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    ...eventData,
  }

  // 乐观更新
  const events = [...store.getState().events, newEvent]
  store.setState({ events })

  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { id: _localId, profiles: _p, ...insertData } = newEvent
    const { data, error } = await supabase
      .from('events')
      .insert(insertData)
      .select('*, profiles:created_by(display_name)')
      .single()

    if (error) {
      // 回滚
      store.setState({ events: store.getState().events.filter(e => e.id !== newEvent.id) })
      showToast('创建事件失败：' + error.message, 'error')
      return null
    }
    // 替换为服务端数据
    store.setState({
      events: store.getState().events.map(e => e.id === newEvent.id ? data : e)
    })
    return data
  }

  // 本地持久化
  saveLocalEvents(timelineId, events)
  return newEvent
}

export async function updateEvent(eventId, updates) {
  const events = store.getState().events
  const idx = events.findIndex(e => e.id === eventId)
  if (idx === -1) return null

  const updated = { ...events[idx], ...updates, updated_at: new Date().toISOString() }
  const newEvents = [...events]
  newEvents[idx] = updated
  store.setState({ events: newEvents })

  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { profiles: _p, ...updateData } = updates
    const { error } = await supabase
      .from('events')
      .update({ ...updateData, updated_at: new Date().toISOString() })
      .eq('id', eventId)

    if (error) {
      // 回滚
      store.setState({ events })
      showToast('更新失败：' + error.message, 'error')
      return null
    }
  } else {
    saveLocalEvents(updated.timeline_id, newEvents)
  }

  return updated
}

export async function deleteEvent(eventId) {
  const events = store.getState().events
  const event = events.find(e => e.id === eventId)
  if (!event) return false

  store.setState({ events: events.filter(e => e.id !== eventId) })

  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { error } = await supabase.from('events').delete().eq('id', eventId)
    if (error) {
      store.setState({ events })
      showToast('删除失败', 'error')
      return false
    }
  } else {
    saveLocalEvents(event.timeline_id, store.getState().events)
  }

  return true
}

/** 按日期分组事件 */
export function groupEventsByDate(events) {
  const groups = new Map()
  for (const event of events) {
    const date = event.event_date
    if (!groups.has(date)) groups.set(date, [])
    groups.get(date).push(event)
  }
  return groups
}

/** 格式化日期标题 */
export function formatDateLabel(dateStr) {
  const date = new Date(dateStr + 'T00:00:00')
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)

  if (date.getTime() === today.getTime()) return '今天'
  if (date.getTime() === tomorrow.getTime()) return '明天'

  return new Intl.DateTimeFormat('zh-CN', {
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  }).format(date)
}

/** 格式化时间 */
export function formatTime(timeStr) {
  if (!timeStr) return '全天'
  return timeStr.slice(0, 5)
}
