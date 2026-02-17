import { h } from '../lib/dom.js'

export function createChatMessage(role, content) {
  const isAi = role === 'ai' || role === 'assistant'

  return h('div', { className: `chat-message ${isAi ? 'ai' : 'user'}` },
    // AI 头像
    isAi
      ? h('div', { className: 'chat-avatar' }, '\u8109')
      : null,
    // 气泡
    h('div', { className: 'message-bubble' },
      isAi ? h('span', { className: 'message-sender' }, '\u8109\u51b2\u52a9\u624b') : null,
      h('div', { className: 'message-content' },
        h('p', {}, content)
      )
    )
  )
}

export function createTypingIndicator() {
  return h('div', { className: 'chat-message ai' },
    h('div', { className: 'chat-avatar' }, '\u8109'),
    h('div', { className: 'message-bubble' },
      h('span', { className: 'message-sender' }, '\u8109\u51b2\u52a9\u624b'),
      h('div', { className: 'message-content' },
        h('div', { className: 'typing-indicator' },
          h('span'), h('span'), h('span')
        )
      )
    )
  )
}

export function createSuggestionChips(suggestions, onSelect) {
  return h('div', { className: 'suggestion-chips' },
    ...suggestions.map(text =>
      h('button', {
        className: 'suggestion-chip',
        onClick: () => onSelect(text)
      }, text)
    )
  )
}
