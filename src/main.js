import { store } from './lib/store.js'
import { getSupabase, isSupabaseConfigured } from './lib/supabase.js'
import { initRouter, addRoute, beforeEach, setViewContainer, navigate } from './router.js'
import { showAuthView } from './views/auth.view.js'
import { showTimelineListView } from './views/timeline-list.view.js'
import { showTimelineView } from './views/timeline.view.js'
import { showChatView } from './views/chat.view.js'
import { showSharePreviewView } from './views/share-preview.view.js'
import { handleJoinInvite } from './services/timeline.service.js'
import './styles/index.css'

async function init() {
  const container = document.getElementById('view-container')
  setViewContainer(container)

  // 监听网络状态
  window.addEventListener('online', () => store.setState({ online: true }))
  window.addEventListener('offline', () => store.setState({ online: false }))

  // iOS 虚拟键盘：调整视口高度避免遮挡输入框
  if (window.visualViewport) {
    const app = document.getElementById('app')
    window.visualViewport.addEventListener('resize', () => {
      app.style.height = `${window.visualViewport.height}px`
    })
  }

  // 初始化 Supabase 认证状态
  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    const { data: { session } } = await supabase.auth.getSession()
    if (session) {
      store.setState({ user: session.user })
    }

    supabase.auth.onAuthStateChange((_event, session) => {
      store.setState({ user: session?.user || null })
      if (!session) navigate('/auth')
    })
  }

  // 路由守卫：未登录用户重定向到认证页
  beforeEach((path) => {
    if (path === '/auth') return true
    if (path.startsWith('/join/')) return true
    if (!store.getState().user) return '/auth'
    return true
  })

  // 注册路由
  addRoute('/auth', (params, container) => showAuthView(container))
  addRoute('/', (params, container) => showTimelineListView(container))
  addRoute('/timeline/:id', (params, container) => showTimelineView(params.id, container))
  addRoute('/timeline/:id/chat', (params, container) => showChatView(params.id, container))
  addRoute('/timeline/:id/share', (params, container) => showSharePreviewView(params.id, container))
  addRoute('/join/:code', async (params) => {
    await handleJoinInvite(params.code)
  })

  initRouter()
}

// 启动
document.addEventListener('DOMContentLoaded', init)
