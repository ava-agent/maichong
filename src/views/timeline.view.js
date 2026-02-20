import { h, clearChildren } from '../lib/dom.js'
import { store } from '../lib/store.js'
import { navigate } from '../router.js'
import { getTimeline, getMembers, generateInviteLink } from '../services/timeline.service.js'
import { listEvents, createEvent, updateEvent, deleteEvent, groupEventsByDate, formatDateLabel } from '../services/event.service.js'
import { subscribeToTimeline, unsubscribeAll } from '../services/realtime.service.js'
import { createHeader, createIcon } from '../components/header.js'
import { createPulseCard, createDateSeparator } from '../components/pulse-card.js'
import { createInputBar } from '../components/input-bar.js'
import { createAvatarStack } from '../components/avatar-stack.js'
import { showEventForm } from '../components/event-form.js'
import { showModal } from '../components/modal.js'
import { showToast } from '../components/toast.js'
import { createLoadingOverlay } from '../components/loading-spinner.js'

export async function showTimelineView(timelineId, container) {
  clearChildren(container)

  const view = h('div', { className: 'view', style: { position: 'relative' } })
  container.appendChild(view)

  // 加载
  view.appendChild(createLoadingOverlay())

  const [timeline, events, members] = await Promise.all([
    getTimeline(timelineId),
    listEvents(timelineId),
    getMembers(timelineId),
  ])

  if (!timeline) {
    clearChildren(view)
    view.appendChild(h('div', { className: 'empty-state' },
      h('h3', { className: 'empty-title' }, '时间线不存在'),
      h('button', { className: 'btn btn-primary btn-sm', onClick: () => navigate('/') }, '返回首页')
    ))
    return { unmount() {} }
  }

  clearChildren(view)

  // Header
  const header = createHeader({
    title: timeline.title,
    left: [{ icon: 'back', label: '返回', onClick: () => navigate('/') }],
    right: [
      { icon: 'invite', label: '邀请', onClick: () => showInviteModal(timelineId) },
      { icon: 'share', label: '分享', onClick: () => navigate(`/timeline/${timelineId}/share`) },
    ]
  })

  // 在标题前插入头像
  const titleEl = header.querySelector('.view-title')
  const avatarStack = createAvatarStack(members)
  avatarStack.style.marginRight = '10px'
  titleEl.parentNode.insertBefore(avatarStack, titleEl)

  view.appendChild(header)

  // 时间线内容
  const body = h('div', { className: 'view-body' })
  const timelineContainer = h('div', { className: 'timeline-container' },
    h('div', { className: 'timeline-axis' })
  )
  body.appendChild(timelineContainer)
  view.appendChild(body)

  // 渲染事件（保留滚动位置）
  function renderEvents(events) {
    const scrollTop = body.scrollTop
    const axis = timelineContainer.querySelector('.timeline-axis')
    clearChildren(timelineContainer)
    timelineContainer.appendChild(axis)

    if (!events || events.length === 0) {
      timelineContainer.appendChild(
        h('div', { className: 'empty-state', style: { paddingBottom: '80px' } },
          h('div', { className: 'empty-icon' }, '\u2728'),
          h('h3', { className: 'empty-title' }, '还没有活动'),
          h('p', { className: 'empty-desc' }, '在下方输入栏中描述你的计划\n或点击 + 按钮手动创建')
        )
      )
      return
    }

    const groups = groupEventsByDate(events)
    for (const [date, items] of groups) {
      timelineContainer.appendChild(createDateSeparator(formatDateLabel(date)))
      for (const event of items) {
        timelineContainer.appendChild(
          createPulseCard(event, {
            onEdit: (evt) => showEventForm(evt, {
              onSave: (data) => updateEvent(evt.id, data),
              onDelete: (id) => deleteEvent(id),
            })
          })
        )
      }
    }

    // 恢复滚动位置
    requestAnimationFrame(() => { body.scrollTop = scrollTop })
  }

  renderEvents(events)

  // 输入栏
  const inputBar = createInputBar({
    placeholder: '描述你的计划，AI 帮你安排...',
    onSend: (text) => navigate(`/timeline/${timelineId}/chat?msg=${encodeURIComponent(text)}`),
    onFocus: () => navigate(`/timeline/${timelineId}/chat`),
  })
  view.appendChild(inputBar)

  // FAB: 手动创建
  const fab = h('button', { className: 'fab', title: '创建事件', onClick: () => {
    showEventForm(null, {
      onSave: (data) => createEvent(timelineId, data)
    })
  }}, createIcon('add'))
  view.appendChild(fab)

  // 订阅 store 变更
  const unsub = store.subscribe('events', (newEvents) => {
    renderEvents(newEvents)
  })

  // 订阅实时更新
  subscribeToTimeline(timelineId)

  return {
    unmount() {
      unsub()
      unsubscribeAll()
    }
  }
}

function showInviteModal(timelineId) {
  const link = generateInviteLink(timelineId)

  const content = h('div', {},
    h('p', { style: { marginBottom: '12px', color: 'var(--text-secondary)', fontSize: '14px' } },
      '分享以下链接给朋友，他们可以加入这个时间线：'
    ),
    h('div', {
      style: {
        background: 'var(--bg-secondary)',
        padding: '12px',
        borderRadius: 'var(--radius-md)',
        fontSize: '13px',
        wordBreak: 'break-all',
        marginBottom: '16px'
      }
    }, link),
    h('button', {
      className: 'btn btn-primary',
      onClick: async () => {
        try {
          await navigator.clipboard.writeText(link)
          showToast('链接已复制', 'success')
          modal.close()
        } catch {
          showToast('请手动复制链接', 'warning')
        }
      }
    }, '复制链接')
  )
  const modal = showModal('邀请成员', content)
}
