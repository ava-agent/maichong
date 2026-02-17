import { h } from '../lib/dom.js'

export function showModal(title, contentEl, options = {}) {
  const { onClose } = options
  let overlay

  function close() {
    if (overlay && overlay.parentNode) {
      overlay.style.opacity = '0'
      const content = overlay.querySelector('.modal-content')
      if (content) content.style.transform = 'translateY(100%)'
      setTimeout(() => {
        if (overlay.parentNode) overlay.parentNode.removeChild(overlay)
      }, 250)
    }
    onClose?.()
  }

  overlay = h('div', {
    className: 'modal-overlay',
    onClick: (e) => { if (e.target === overlay) close() }
  },
    h('div', { className: 'modal-content' },
      h('div', { className: 'modal-handle' }),
      h('div', { className: 'modal-header' },
        h('h2', { className: 'modal-title' }, title),
        h('button', { className: 'modal-close', onClick: close }, '\u00d7')
      ),
      contentEl
    )
  )

  document.body.appendChild(overlay)
  return { close, overlay }
}
