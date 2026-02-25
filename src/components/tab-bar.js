import { h } from '../lib/dom.js'
import { store } from '../lib/store.js'
import { navigate, getCurrentPath } from '../router.js'
import { createLucideIcon } from './icons.js'

const TABS = [
  { id: 'home', label: '首页', icon: 'house', path: '/' },
  { id: 'timeline', label: '时间线', icon: 'calendar-days', pathSuffix: '' },
  { id: 'chat', label: 'AI助手', icon: 'message-circle', pathSuffix: '/chat' },
  { id: 'profile', label: '我的', icon: 'user', path: '/profile' },
]

let tabBarEl = null

export function initTabBar() {
  tabBarEl = document.getElementById('tab-bar')
  if (!tabBarEl) return

  tabBarEl.setAttribute('role', 'tablist')
  tabBarEl.setAttribute('aria-label', '主导航')

  TABS.forEach(tab => {
    const item = h('div', {
      className: 'tab-item',
      role: 'tab',
      'aria-label': tab.label,
      'aria-selected': 'false',
      tabIndex: '0',
      dataset: { tab: tab.id },
    },
      createLucideIcon(tab.icon, { size: 24, strokeWidth: 1.75 }),
      h('span', { className: 'tab-label' }, tab.label)
    )
    item.addEventListener('click', () => handleTabClick(tab))
    tabBarEl.appendChild(item)
  })
}

function handleTabClick(tab) {
  if (tab.path) {
    navigate(tab.path)
    return
  }

  // Contextual tabs (timeline, chat) need a timeline ID
  const lastId = store.getState().lastTimelineId
  if (lastId) {
    navigate(`/timeline/${lastId}${tab.pathSuffix}`)
  } else {
    // No timeline visited yet — go home
    navigate('/')
  }
}

export function updateTabBar(path) {
  if (!tabBarEl) return

  // Determine visibility
  const shouldHide =
    path === '/auth' ||
    path.startsWith('/join/') ||
    path.endsWith('/share')

  tabBarEl.classList.toggle('hidden', shouldHide)

  // Determine active tab
  let activeId = 'home'
  if (path === '/profile') {
    activeId = 'profile'
  } else if (/^\/timeline\/[^/]+\/chat/.test(path)) {
    activeId = 'chat'
  } else if (/^\/timeline\/[^/]+/.test(path)) {
    activeId = 'timeline'
  }

  tabBarEl.querySelectorAll('.tab-item').forEach(item => {
    const isActive = item.dataset.tab === activeId
    item.classList.toggle('active', isActive)
    item.setAttribute('aria-selected', String(isActive))
  })
}
