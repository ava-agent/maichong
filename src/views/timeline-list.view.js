import { h, clearChildren } from '../lib/dom.js'
import { store } from '../lib/store.js'
import { navigate } from '../router.js'
import { createTimeline, listMyTimelines, deleteTimeline } from '../services/timeline.service.js'
import { getUserDisplayName } from '../services/auth.service.js'
import { createHeader } from '../components/header.js'
import { createLucideIcon } from '../components/icons.js'
import { showModal } from '../components/modal.js'
import { showToast } from '../components/toast.js'
import { createLoadingOverlay } from '../components/loading-spinner.js'

function getGreeting() {
  const h = new Date().getHours()
  if (h < 6) return '夜深了'
  if (h < 12) return '早上好'
  if (h < 14) return '中午好'
  if (h < 18) return '下午好'
  return '晚上好'
}

export async function showTimelineListView(container) {
  clearChildren(container)

  const view = h('div', { className: 'view', style: { position: 'relative' } })

  // Simplified header — no logout button (moved to profile tab)
  const header = createHeader({ title: '脉冲' })
  view.appendChild(header)

  const body = h('div', { className: 'view-body scrollable' })
  view.appendChild(body)

  body.appendChild(createLoadingOverlay('加载中...'))
  container.appendChild(view)

  const timelines = await listMyTimelines()
  clearChildren(body)
  renderList(body, timelines)

  // FAB above tab bar
  const fab = h('button', {
    className: 'fab above-tab-bar',
    title: '创建时间线',
    onClick: showCreateForm
  }, createLucideIcon('plus', { size: 24, strokeWidth: 2, color: 'white' }))
  view.appendChild(fab)

  const unsub = store.subscribe('timelines', (newTimelines) => {
    clearChildren(body)
    renderList(body, newTimelines)
  })

  return { unmount() { unsub() } }
}

function renderList(body, timelines) {
  const user = store.getState().user
  const name = getUserDisplayName(user)

  if (!timelines || timelines.length === 0) {
    body.appendChild(
      h('div', { className: 'timeline-list' },
        h('div', { className: 'greeting-section' },
          h('h2', { className: 'greeting-text' }, `${getGreeting()}，${name}`),
          h('p', { className: 'greeting-sub' }, '开始规划你的第一个时间线吧')
        ),
        h('div', { className: 'empty-state', style: { paddingTop: '24px' } },
          h('div', { className: 'empty-icon' }, '✨'),
          h('h3', { className: 'empty-title' }, '还没有时间线'),
          h('p', { className: 'empty-desc' }, '点击右下角 + 按钮创建')
        )
      )
    )
    return
  }

  const list = h('div', { className: 'timeline-list' },
    h('div', { className: 'greeting-section' },
      h('h2', { className: 'greeting-text' }, `${getGreeting()}，${name}`),
      h('p', { className: 'greeting-sub' }, `你有 ${timelines.length} 个时间线`)
    ),
    ...timelines.map((tl, i) =>
      h('div', {
        className: 'timeline-card slide-up',
        style: { animationDelay: `${i * 0.06}s` },
        dataset: { id: tl.id }
      },
        h('div', { className: 'timeline-card-header' },
          h('div', { className: 'timeline-card-icon' }, '📅'),
          h('div', { className: 'timeline-card-info' },
            h('h3', { className: 'timeline-card-title' }, tl.title),
            h('p', { className: 'timeline-card-meta' }, formatDate(tl.created_at))
          )
        ),
        h('div', { className: 'timeline-card-arrow' },
          createLucideIcon('chevron-right', { size: 18, strokeWidth: 1.5 })
        )
      )
    )
  )

  // Event delegation: single listener on list for all cards
  let pressTimer
  list.addEventListener('click', (e) => {
    const card = e.target.closest('.timeline-card')
    if (card?.dataset.id) navigate(`/timeline/${card.dataset.id}`)
  })
  list.addEventListener('pointerdown', (e) => {
    const card = e.target.closest('.timeline-card')
    if (!card?.dataset.id) return
    const tl = timelines.find(t => t.id === card.dataset.id)
    if (tl) pressTimer = setTimeout(() => showDeleteConfirm(tl), 600)
  })
  list.addEventListener('pointerup', () => clearTimeout(pressTimer))
  list.addEventListener('pointerleave', () => clearTimeout(pressTimer))

  body.appendChild(list)
}

function showCreateForm() {
  const input = h('input', {
    className: 'form-input',
    type: 'text',
    placeholder: '例如：周末家庭出游',
    style: { marginBottom: '16px' }
  })

  const btn = h('button', {
    className: 'btn btn-primary',
    onClick: async () => {
      const title = input.value.trim()
      if (!title) { input.focus(); return }
      btn.textContent = '创建中...'
      btn.disabled = true
      const tl = await createTimeline(title)
      modal.close()
      if (tl) navigate(`/timeline/${tl.id}`)
    }
  }, '创建时间线')

  const content = h('div', {}, input, btn)
  const modal = showModal('新建时间线', content)
  setTimeout(() => input.focus(), 150)
}

function showDeleteConfirm(tl) {
  const content = h('div', {},
    h('p', { style: { marginBottom: '16px', color: 'var(--text-secondary)', fontSize: '14px' } },
      `确定要删除「${tl.title}」吗？此操作不可撤销。`
    ),
    h('button', {
      className: 'btn btn-danger w-full',
      onClick: async () => {
        await deleteTimeline(tl.id)
        modal.close()
        showToast('已删除', 'success')
      }
    }, '删除')
  )
  const modal = showModal('删除时间线', content)
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return new Intl.DateTimeFormat('zh-CN', { month: 'long', day: 'numeric' }).format(d) + '创建'
}
