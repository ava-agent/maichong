import { h, clearChildren } from '../lib/dom.js'
import { store } from '../lib/store.js'
import { navigate } from '../router.js'
import { sendChatMessage, loadChatHistory } from '../services/ai.service.js'
import { getTimeline } from '../services/timeline.service.js'
import { createHeader } from '../components/header.js'
import { createChatMessage, createTypingIndicator, createSuggestionChips } from '../components/chat-message.js'
import { createInputBar } from '../components/input-bar.js'
import { showToast } from '../components/toast.js'

const SUGGESTIONS = [
  '周六下午喝咖啡',
  '安排一个晚餐',
  '这周末去爬山',
  '明天上午开会'
]

export async function showChatView(timelineId, container) {
  clearChildren(container)

  const view = h('div', { className: 'view', style: { position: 'relative' } })
  container.appendChild(view)

  const timeline = store.getState().currentTimeline || await getTimeline(timelineId)

  // Header — no back button (tab bar "时间线" tab provides navigation)
  const header = createHeader({
    title: 'AI 脉冲助手',
    left: [],
    right: [{ icon: 'timeline', label: '时间线', onClick: () => navigate(`/timeline/${timelineId}`) }]
  })
  view.appendChild(header)

  const chatLog = h('div', { className: 'chat-container scrollable' })
  view.appendChild(chatLog)

  const history = await loadChatHistory(timelineId)

  if (history.length === 0) {
    // Enhanced welcome area with capability cards
    chatLog.appendChild(
      h('div', { className: 'chat-welcome' },
        h('div', { className: 'chat-welcome-avatar' },
          h('div', { className: 'chat-welcome-icon' }, '脉')
        ),
        h('h2', { className: 'chat-welcome-title' }, '你好，我是脉冲助手 ✨'),
        h('p', { className: 'chat-welcome-desc' },
          '告诉我你的计划，我会帮你智能安排到时间线上'
        ),
        // Capability cards (Doubao-style)
        h('div', { className: 'capability-cards' },
          createCapabilityCard('📅', '安排计划', '告诉我时间和活动'),
          createCapabilityCard('✏️', '修改事件', '调整已有的安排'),
          createCapabilityCard('🔍', '查询日程', '查看你的时间线')
        )
      )
    )
    // Suggestion chips
    chatLog.appendChild(
      createSuggestionChips(SUGGESTIONS, (text) => {
        inputBar.setValue(text)
        inputBar.querySelector('.send-btn')?.click()
      })
    )
  } else {
    history.forEach(msg => {
      chatLog.appendChild(createChatMessage(msg.role === 'assistant' ? 'ai' : 'user', msg.content))
    })
  }

  let isSending = false
  const inputBar = createInputBar({
    placeholder: '告诉我你的计划...',
    aboveTabBar: true,
    onSend: async (text) => {
      if (isSending) return
      isSending = true

      // Remove welcome and suggestion chips
      const welcome = chatLog.querySelector('.chat-welcome')
      if (welcome) welcome.remove()
      const chips = chatLog.querySelector('.suggestion-chips')
      if (chips) chips.remove()

      chatLog.appendChild(createChatMessage('user', text))
      scrollToBottom()

      const typing = createTypingIndicator()
      chatLog.appendChild(typing)
      scrollToBottom()

      try {
        const result = await sendChatMessage(timelineId, text)
        if (typing.parentNode) typing.remove()

        chatLog.appendChild(createChatMessage('ai', result.reply))
        scrollToBottom()

        if (result.action) {
          const labels = {
            create_event: '✓ 已添加到时间线',
            update_event: '✓ 已更新事件',
            delete_event: '✓ 已删除事件'
          }
          showToast(labels[result.action.type] || '操作已执行', 'success')
        }
      } catch {
        if (typing.parentNode) typing.remove()
        chatLog.appendChild(createChatMessage('ai', '抱歉，出了点问题，请稍后再试。'))
        scrollToBottom()
      }

      isSending = false
    }
  })
  view.appendChild(inputBar)

  function scrollToBottom() {
    requestAnimationFrame(() => { chatLog.scrollTop = chatLog.scrollHeight })
  }

  scrollToBottom()

  // URL pre-filled message
  const urlParams = new URLSearchParams(window.location.hash.split('?')[1] || '')
  const preMsg = urlParams.get('msg')
  if (preMsg) {
    setTimeout(() => {
      inputBar.setValue(preMsg)
      inputBar.querySelector('.send-btn').click()
    }, 300)
  } else {
    setTimeout(() => inputBar.focusInput(), 200)
  }

  return { unmount() {} }
}

function createCapabilityCard(emoji, title, desc) {
  return h('div', { className: 'capability-card' },
    h('span', { className: 'capability-emoji' }, emoji),
    h('div', { className: 'capability-text' },
      h('span', { className: 'capability-title' }, title),
      h('span', { className: 'capability-desc' }, desc)
    )
  )
}
