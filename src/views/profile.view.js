import { h, clearChildren } from '../lib/dom.js'
import { store } from '../lib/store.js'
import { getUserDisplayName, signOut } from '../services/auth.service.js'
import { createLucideIcon } from '../components/icons.js'

export function showProfileView(container) {
  clearChildren(container)
  const user = store.getState().user
  const name = getUserDisplayName(user)
  const initial = name.charAt(0).toUpperCase()

  const view = h('div', { className: 'view' })
  const body = h('div', { className: 'view-body scrollable' },
    // Profile header
    h('div', { className: 'profile-header' },
      h('div', { className: 'profile-avatar' }, initial),
      h('h2', { className: 'profile-name' }, name),
      h('p', { className: 'profile-email' }, user?.email || '演示模式')
    ),
    // Settings section
    h('div', { className: 'profile-section' },
      createProfileItem('settings', '设置'),
      createProfileItem('info', '关于脉冲'),
    ),
    // Logout section
    h('div', { className: 'profile-section' },
      createProfileItem('log-out', '退出登录', () => signOut(), true),
    )
  )

  view.appendChild(body)
  container.appendChild(view)
  return { unmount() {} }
}

function createProfileItem(icon, label, onClick, isDanger = false) {
  return h('div', {
    className: `profile-item ${isDanger ? 'danger' : ''}`,
    onClick: onClick || (() => {})
  },
    createLucideIcon(icon, { size: 20, strokeWidth: 1.75 }),
    h('span', { className: 'profile-item-label' }, label),
    createLucideIcon('chevron-right', { size: 16, strokeWidth: 1.5 })
  )
}
