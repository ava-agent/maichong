/**
 * 响应式状态管理 (pub/sub pattern)
 */
export function createStore(initialState) {
  let state = { ...initialState }
  const listeners = new Map()

  function getState() {
    return state
  }

  function setState(partial) {
    const prev = state
    state = { ...state, ...partial }
    for (const [key, callbacks] of listeners) {
      if (prev[key] !== state[key]) {
        callbacks.forEach(cb => cb(state[key], prev[key]))
      }
    }
  }

  function subscribe(key, callback) {
    if (!listeners.has(key)) listeners.set(key, new Set())
    listeners.get(key).add(callback)
    // 立即用当前值调用一次
    callback(state[key], undefined)
    return () => listeners.get(key).delete(callback)
  }

  return { getState, setState, subscribe }
}

// 全局 store 单例
export const store = createStore({
  user: null,
  timelines: [],
  currentTimeline: null,
  events: [],
  members: [],
  chatMessages: [],
  loading: false,
  online: navigator.onLine,
  lastTimelineId: null,
})
