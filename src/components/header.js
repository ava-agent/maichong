import { h } from '../lib/dom.js'
import { createLucideIcon } from './icons.js'

// Map legacy icon names to Lucide icon names
const ICON_MAP = {
  back: 'arrow-left',
  share: 'share-2',
  timeline: 'calendar-days',
  chat: 'message-circle',
  add: 'plus',
  delete: 'trash-2',
  settings: 'ellipsis-vertical',
  invite: 'user-plus',
  logout: 'log-out',
  copy: 'copy',
}

export function createIcon(name) {
  const lucideName = ICON_MAP[name] || name
  return createLucideIcon(lucideName, { size: 22, strokeWidth: 1.75 })
}

export function createHeader({ title, left = [], right = [] }) {
  return h('header', { className: 'view-header' },
    h('div', { className: 'header-left' },
      ...left.map(btn => createHeaderBtn(btn))
    ),
    h('h1', { className: 'view-title' }, title),
    h('div', { className: 'header-right' },
      ...right.map(btn => createHeaderBtn(btn))
    )
  )
}

function createHeaderBtn({ icon, label, onClick }) {
  return h('button', {
    className: 'header-btn',
    title: label || '',
    onClick
  }, createIcon(icon))
}
