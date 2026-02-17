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
  '\u5468\u516d\u4e0b\u5348\u559d\u5496\u5561',
  '\u5b89\u6392\u4e00\u4e2a\u665a\u9910',
  '\u8fd9\u5468\u672b\u53bb\u722c\u5c71',
  '\u660e\u5929\u4e0a\u5348\u5f00\u4f1a'
]

export async function showChatView(timelineId, container) {
  clearChildren(container)

  const view = h('div', { className: 'view', style: { position: 'relative' } })
  container.appendChild(view)

  const timeline = store.getState().currentTimeline || await getTimeline(timelineId)

  const header = createHeader({
    title: 'AI \u8109\u51b2\u52a9\u624b',
    left: [{ icon: 'back', label: '\u8fd4\u56de', onClick: () => navigate(`/timeline/${timelineId}`) }],
    right: [{ icon: 'timeline', label: '\u65f6\u95f4\u7ebf', onClick: () => navigate(`/timeline/${timelineId}`) }]
  })
  header.classList.add('gradient-header')
  view.appendChild(header)

  const chatLog = h('div', { className: 'chat-container scrollable' })
  view.appendChild(chatLog)

  const history = await loadChatHistory(timelineId)

  if (history.length === 0) {
    // \u6b22\u8fce\u533a\u57df
    chatLog.appendChild(
      h('div', { className: 'chat-welcome' },
        h('div', { className: 'chat-welcome-icon' }, '\u8109'),
        h('h2', { className: 'chat-welcome-title' }, '\u4f60\u597d\uff0c\u6211\u662f\u8109\u51b2\u52a9\u624b'),
        h('p', { className: 'chat-welcome-desc' },
          '\u544a\u8bc9\u6211\u4f60\u7684\u8ba1\u5212\uff0c\u6211\u4f1a\u5e2e\u4f60\u667a\u80fd\u5b89\u6392\u5230\u65f6\u95f4\u7ebf\u4e0a'
        )
      )
    )
    // \u5efa\u8bae\u6807\u7b7e
    chatLog.appendChild(
      createSuggestionChips(SUGGESTIONS, (text) => {
        inputBar._input.value = text
        inputBar.querySelector('.send-btn').click()
      })
    )
  } else {
    history.forEach(msg => {
      chatLog.appendChild(createChatMessage(msg.role === 'assistant' ? 'ai' : 'user', msg.content))
    })
  }

  let isSending = false
  const inputBar = createInputBar({
    placeholder: '\u544a\u8bc9\u6211\u4f60\u7684\u8ba1\u5212...',
    onSend: async (text) => {
      if (isSending) return
      isSending = true

      // \u79fb\u9664\u6b22\u8fce\u548c\u5efa\u8bae
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
            create_event: '\u2713 \u5df2\u6dfb\u52a0\u5230\u65f6\u95f4\u7ebf',
            update_event: '\u2713 \u5df2\u66f4\u65b0\u4e8b\u4ef6',
            delete_event: '\u2713 \u5df2\u5220\u9664\u4e8b\u4ef6'
          }
          showToast(labels[result.action.type] || '\u64cd\u4f5c\u5df2\u6267\u884c', 'success')
        }
      } catch {
        if (typing.parentNode) typing.remove()
        chatLog.appendChild(createChatMessage('ai', '\u62b1\u6b49\uff0c\u51fa\u4e86\u70b9\u95ee\u9898\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5\u3002'))
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

  // URL \u9884\u586b\u6d88\u606f
  const urlParams = new URLSearchParams(window.location.hash.split('?')[1] || '')
  const preMsg = urlParams.get('msg')
  if (preMsg) {
    setTimeout(() => {
      inputBar._input.value = preMsg
      inputBar.querySelector('.send-btn').click()
    }, 300)
  } else {
    setTimeout(() => inputBar._input.focus(), 200)
  }

  return { unmount() {} }
}
