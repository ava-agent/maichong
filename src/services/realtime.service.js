import { getSupabase, isSupabaseConfigured } from '../lib/supabase.js'
import { store } from '../lib/store.js'

let channels = []
let currentTimelineId = null

export function subscribeToTimeline(timelineId) {
  if (!isSupabaseConfigured()) return

  // Prevent duplicate subscriptions for same timeline
  if (currentTimelineId === timelineId && channels.length > 0) return

  // Clean up previous subscriptions
  unsubscribeAll()
  currentTimelineId = timelineId

  const supabase = getSupabase()

  const eventsChannel = supabase
    .channel(`events:${timelineId}`)
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'events',
      filter: `timeline_id=eq.${timelineId}`
    }, (payload) => {
      const events = store.getState().events

      if (payload.eventType === 'INSERT') {
        if (!events.find(e => e.id === payload.new.id)) {
          store.setState({ events: [...events, payload.new] })
        }
      } else if (payload.eventType === 'UPDATE') {
        store.setState({
          events: events.map(e => e.id === payload.new.id ? { ...e, ...payload.new } : e)
        })
      } else if (payload.eventType === 'DELETE') {
        store.setState({
          events: events.filter(e => e.id !== payload.old.id)
        })
      }
    })
    .subscribe()

  const membersChannel = supabase
    .channel(`members:${timelineId}`)
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'timeline_members',
      filter: `timeline_id=eq.${timelineId}`
    }, (payload) => {
      const members = store.getState().members
      if (payload.eventType === 'INSERT') {
        if (!members.find(m => m.id === payload.new.id)) {
          store.setState({ members: [...members, payload.new] })
        }
      } else if (payload.eventType === 'DELETE') {
        store.setState({
          members: members.filter(m => m.id !== payload.old.id)
        })
      }
    })
    .subscribe()

  channels.push(eventsChannel, membersChannel)
}

export function unsubscribeAll() {
  if (!isSupabaseConfigured() || channels.length === 0) return
  const supabase = getSupabase()
  channels.forEach(ch => supabase.removeChannel(ch))
  channels = []
  currentTimelineId = null
}
