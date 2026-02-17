import { h } from '../lib/dom.js'
import { formatTime } from '../services/event.service.js'

/**
 * 创建脉冲事件卡片
 */
export function createPulseCard(event, { onEdit, onDelete } = {}) {
  const statusClass = `status-${event.status || 'confirmed'}`
  const time = event.is_all_day ? '全天' : formatTime(event.start_time)

  const card = h('div', { className: 'timeline-node fade-in-scale' },
    h('div', { className: `pulse-card ${statusClass}`, dataset: { id: event.id } },
      h('p', { className: 'card-time' }, time),
      h('h2', { className: 'card-title' }, event.title),
      event.description
        ? h('p', { className: 'card-desc' }, event.description)
        : null,
      event.profiles?.display_name
        ? h('div', { className: 'card-meta' },
            h('span', {}, `由 ${event.profiles.display_name} 创建`)
          )
        : null
    )
  )

  // 点击编辑
  if (onEdit) {
    card.querySelector('.pulse-card').addEventListener('click', () => onEdit(event))
  }

  return card
}

/**
 * 创建日期分隔器
 */
export function createDateSeparator(label) {
  return h('div', { className: 'date-separator' },
    h('span', { className: 'date-label' }, label)
  )
}
