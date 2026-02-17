import { h } from '../lib/dom.js'

export function createSpinner(size = 'md') {
  const sizes = { sm: '20px', md: '32px', lg: '48px' }
  const s = sizes[size] || sizes.md

  const spinner = h('div', {
    className: 'loading-spinner',
    style: {
      width: s,
      height: s,
      border: '3px solid var(--border-color)',
      borderTopColor: 'var(--primary-color)',
      borderRadius: '50%',
      animation: 'spin 0.6s linear infinite',
    }
  })

  // 注入动画（只需一次）
  if (!document.getElementById('spinner-keyframes')) {
    const style = document.createElement('style')
    style.id = 'spinner-keyframes'
    style.textContent = '@keyframes spin { to { transform: rotate(360deg); } }'
    document.head.appendChild(style)
  }

  return spinner
}

export function createLoadingOverlay(message = '加载中...') {
  return h('div', { className: 'empty-state', style: { padding: '40px 20px' } },
    createSpinner(),
    h('p', { className: 'text-secondary', style: { marginTop: '12px', fontSize: '14px' } }, message)
  )
}
