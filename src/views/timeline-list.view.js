import { h, clearChildren } from '../lib/dom.js'
import { store } from '../lib/store.js'
import { navigate } from '../router.js'
import { createTimeline, listMyTimelines, deleteTimeline } from '../services/timeline.service.js'
import { signOut, getUserDisplayName } from '../services/auth.service.js'
import { createHeader, createIcon } from '../components/header.js'
import { showModal } from '../components/modal.js'
import { showToast } from '../components/toast.js'
import { createLoadingOverlay } from '../components/loading-spinner.js'

function getGreeting() {
  const h = new Date().getHours()
  if (h < 6) return '\u591c\u6df1\u4e86'
  if (h < 12) return '\u65e9\u4e0a\u597d'
  if (h < 14) return '\u4e2d\u5348\u597d'
  if (h < 18) return '\u4e0b\u5348\u597d'
  return '\u665a\u4e0a\u597d'
}

export async function showTimelineListView(container) {
  clearChildren(container)

  const view = h('div', { className: 'view', style: { position: 'relative' } })

  const header = createHeader({
    title: '\u8109\u51b2',
    right: [{ icon: 'logout', label: '\u9000\u51fa', onClick: () => signOut() }]
  })
  view.appendChild(header)

  const body = h('div', { className: 'view-body scrollable' })
  view.appendChild(body)

  body.appendChild(createLoadingOverlay('\u52a0\u8f7d\u4e2d...'))
  container.appendChild(view)

  const timelines = await listMyTimelines()
  clearChildren(body)
  renderList(body, timelines)

  const fab = h('button', { className: 'fab', title: '\u521b\u5efa\u65f6\u95f4\u7ebf', onClick: showCreateForm },
    createIcon('add')
  )
  fab.style.bottom = '20px'
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
          h('h2', { className: 'greeting-text' }, `${getGreeting()}\uff0c${name}`),
          h('p', { className: 'greeting-sub' }, '\u5f00\u59cb\u89c4\u5212\u4f60\u7684\u7b2c\u4e00\u4e2a\u65f6\u95f4\u7ebf\u5427')
        ),
        h('div', { className: 'empty-state', style: { paddingTop: '24px' } },
          h('div', { className: 'empty-icon' }, '\u2728'),
          h('h3', { className: 'empty-title' }, '\u8fd8\u6ca1\u6709\u65f6\u95f4\u7ebf'),
          h('p', { className: 'empty-desc' }, '\u70b9\u51fb\u53f3\u4e0b\u89d2 + \u6309\u94ae\u521b\u5efa')
        )
      )
    )
    return
  }

  const list = h('div', { className: 'timeline-list' },
    h('div', { className: 'greeting-section' },
      h('h2', { className: 'greeting-text' }, `${getGreeting()}\uff0c${name}`),
      h('p', { className: 'greeting-sub' }, `\u4f60\u6709 ${timelines.length} \u4e2a\u65f6\u95f4\u7ebf`)
    ),
    ...timelines.map((tl, i) =>
      h('div', {
        className: 'timeline-card slide-up',
        style: { animationDelay: `${i * 0.06}s` },
        dataset: { id: tl.id }
      },
        h('h3', { className: 'timeline-card-title' }, tl.title),
        h('p', { className: 'timeline-card-meta' }, formatDate(tl.created_at))
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
    placeholder: '\u4f8b\u5982\uff1a\u5468\u672b\u5bb6\u5ead\u51fa\u6e38',
    style: { marginBottom: '16px' }
  })

  const btn = h('button', {
    className: 'btn btn-primary',
    onClick: async () => {
      const title = input.value.trim()
      if (!title) { input.focus(); return }
      btn.textContent = '\u521b\u5efa\u4e2d...'
      btn.disabled = true
      const tl = await createTimeline(title)
      modal.close()
      if (tl) navigate(`/timeline/${tl.id}`)
    }
  }, '\u521b\u5efa\u65f6\u95f4\u7ebf')

  const content = h('div', {}, input, btn)
  const modal = showModal('\u65b0\u5efa\u65f6\u95f4\u7ebf', content)
  setTimeout(() => input.focus(), 150)
}

function showDeleteConfirm(tl) {
  const content = h('div', {},
    h('p', { style: { marginBottom: '16px', color: 'var(--text-secondary)', fontSize: '14px' } },
      `\u786e\u5b9a\u8981\u5220\u9664\u300c${tl.title}\u300d\u5417\uff1f\u6b64\u64cd\u4f5c\u4e0d\u53ef\u64a4\u9500\u3002`
    ),
    h('button', {
      className: 'btn btn-danger w-full',
      onClick: async () => {
        await deleteTimeline(tl.id)
        modal.close()
        showToast('\u5df2\u5220\u9664', 'success')
      }
    }, '\u5220\u9664')
  )
  const modal = showModal('\u5220\u9664\u65f6\u95f4\u7ebf', content)
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return new Intl.DateTimeFormat('zh-CN', { month: 'long', day: 'numeric' }).format(d) + '\u521b\u5efa'
}
