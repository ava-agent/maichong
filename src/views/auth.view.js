import { h, clearChildren } from '../lib/dom.js'
import { signIn, signUp } from '../services/auth.service.js'
import { isSupabaseConfigured } from '../lib/supabase.js'
import { navigate } from '../router.js'
import { store } from '../lib/store.js'

export function showAuthView(container) {
  clearChildren(container)

  if (!isSupabaseConfigured()) {
    return showDemoAuth(container)
  }

  let isSignUp = false
  let errorMsg = ''

  function render() {
    clearChildren(container)

    const errorEl = h('p', { className: 'auth-error' }, errorMsg)

    const form = h('form', { className: 'auth-form' },
      errorEl,
      isSignUp ? h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '\u6635\u79f0'),
        h('input', { className: 'form-input', type: 'text', name: 'displayName', placeholder: '\u4f60\u7684\u6635\u79f0', required: 'true' })
      ) : null,
      h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '\u90ae\u7bb1'),
        h('input', { className: 'form-input', type: 'email', name: 'email', placeholder: 'hello@example.com', required: 'true' })
      ),
      h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '\u5bc6\u7801'),
        h('input', { className: 'form-input', type: 'password', name: 'password', placeholder: '\u81f3\u5c11 6 \u4f4d', required: 'true', minLength: '6' })
      ),
      h('button', { className: 'btn btn-primary', type: 'submit' },
        isSignUp ? '\u521b\u5efa\u8d26\u53f7' : '\u767b\u5f55'
      )
    )

    form.addEventListener('submit', async (e) => {
      e.preventDefault()
      const fd = new FormData(form)
      const email = fd.get('email')
      const password = fd.get('password')
      const btn = form.querySelector('.btn-primary')
      btn.textContent = '\u8bf7\u7a0d\u5019...'
      btn.disabled = true

      let result
      if (isSignUp) {
        result = await signUp(email, password, fd.get('displayName'))
      } else {
        result = await signIn(email, password)
      }

      if (result.error) {
        errorMsg = result.error.message || '\u64cd\u4f5c\u5931\u8d25\uff0c\u8bf7\u91cd\u8bd5'
        btn.textContent = isSignUp ? '\u521b\u5efa\u8d26\u53f7' : '\u767b\u5f55'
        btn.disabled = false
        errorEl.textContent = errorMsg
        errorEl.classList.add('shake')
        setTimeout(() => errorEl.classList.remove('shake'), 300)
      }
    })

    const switchLink = h('a', {
      onClick: () => { isSignUp = !isSignUp; errorMsg = ''; render() }
    }, isSignUp ? '\u5df2\u6709\u8d26\u53f7\uff1f\u767b\u5f55' : '\u6ca1\u6709\u8d26\u53f7\uff1f\u6ce8\u518c')

    const page = h('div', { className: 'auth-page' },
      h('div', { className: 'auth-logo' }, '\u8109'),
      h('h1', { className: 'auth-title' }, '\u8109\u51b2'),
      h('p', { className: 'auth-subtitle' }, '\u540c\u6b65\u6bcf\u6b21\u8109\u51b2'),
      form,
      h('p', { className: 'auth-switch' }, switchLink)
    )

    container.appendChild(page)
  }

  render()
  return { unmount() {} }
}

function showDemoAuth(container) {
  const page = h('div', { className: 'auth-page' },
    h('div', { className: 'auth-logo' }, '\u8109'),
    h('h1', { className: 'auth-title' }, '\u8109\u51b2'),
    h('p', { className: 'auth-subtitle' }, '\u540c\u6b65\u6bcf\u6b21\u8109\u51b2'),
    h('span', { className: 'demo-badge' }, '\u6f14\u793a\u6a21\u5f0f'),
    h('div', { className: 'auth-form' },
      h('button', {
        className: 'btn btn-primary',
        onClick: () => {
          const user = {
            id: crypto.randomUUID(),
            email: 'demo@maichong.app',
            user_metadata: { display_name: '\u6f14\u793a\u7528\u6237' }
          }
          store.setState({ user })
          navigate('/')
        }
      }, '\u5f00\u59cb\u4f53\u9a8c')
    )
  )
  container.appendChild(page)
  return { unmount() {} }
}
