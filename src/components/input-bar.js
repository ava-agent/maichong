import { h } from '../lib/dom.js'

const SEND_ICON = '<svg viewBox="0 -960 960 960"><path d="M120-160v-240l320-80-320-80v-240l760 320-760 320Z"/></svg>'

export function createInputBar({ placeholder = '输入你的计划...', onSend, onFocus } = {}) {
  const input = h('input', {
    className: 'input-field',
    type: 'text',
    placeholder,
  })

  const sendBtn = h('button', {
    className: 'send-btn',
    innerHTML: SEND_ICON,
    title: '发送',
  })

  function handleSend() {
    const text = input.value.trim()
    if (!text) return
    onSend?.(text)
    input.value = ''
  }

  sendBtn.addEventListener('click', handleSend)
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.isComposing) {
      e.preventDefault()
      handleSend()
    }
  })

  if (onFocus) {
    input.addEventListener('focus', onFocus)
  }

  const bar = h('footer', { className: 'input-bar' }, input, sendBtn)

  // Public API
  bar.setValue = (val) => { input.value = val }
  bar.getValue = () => input.value
  bar.focusInput = () => input.focus()

  return bar
}
