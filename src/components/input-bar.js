import { h } from '../lib/dom.js'
import { createLucideIcon } from './icons.js'

export function createInputBar({ placeholder = '输入你的计划...', onSend, onFocus, aboveTabBar = false } = {}) {
  const input = h('input', {
    className: 'input-field',
    type: 'text',
    placeholder,
  })

  const sendBtn = h('button', { className: 'send-btn', title: '发送' },
    createLucideIcon('send-horizontal', { size: 18, strokeWidth: 2 })
  )

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

  const bar = h('footer', {
    className: `input-bar${aboveTabBar ? ' above-tab-bar' : ''}`
  }, input, sendBtn)

  // Public API
  bar.setValue = (val) => { input.value = val }
  bar.getValue = () => input.value
  bar.focusInput = () => input.focus()

  return bar
}
