import { h, clearChildren } from '../lib/dom.js'
import { signIn, signUp } from '../services/auth.service.js'
import { isSupabaseConfigured } from '../lib/supabase.js'
import { navigate } from '../router.js'
import { store } from '../lib/store.js'
import { createLucideIcon } from '../components/icons.js'

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
        h('label', { className: 'form-label' }, '昵称'),
        h('input', { className: 'form-input', type: 'text', name: 'displayName', placeholder: '你的昵称', required: 'true' })
      ) : null,
      h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '邮箱'),
        h('input', { className: 'form-input', type: 'email', name: 'email', placeholder: 'hello@example.com', required: 'true' })
      ),
      h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '密码'),
        h('input', { className: 'form-input', type: 'password', name: 'password', placeholder: '至少 6 位', required: 'true', minLength: '6' })
      ),
      h('button', { className: 'btn btn-primary', type: 'submit' },
        isSignUp ? '创建账号' : '登录'
      )
    )

    form.addEventListener('submit', async (e) => {
      e.preventDefault()
      const fd = new FormData(form)
      const email = fd.get('email')
      const password = fd.get('password')
      const btn = form.querySelector('.btn-primary')
      btn.textContent = '请稍候...'
      btn.disabled = true

      let result
      if (isSignUp) {
        result = await signUp(email, password, fd.get('displayName'))
      } else {
        result = await signIn(email, password)
      }

      if (result.error) {
        errorMsg = result.error.message || '操作失败，请重试'
        btn.textContent = isSignUp ? '创建账号' : '登录'
        btn.disabled = false
        errorEl.textContent = errorMsg
        errorEl.classList.add('shake')
        setTimeout(() => errorEl.classList.remove('shake'), 300)
      }
    })

    const switchLink = h('a', {
      onClick: () => { isSignUp = !isSignUp; errorMsg = ''; render() }
    }, isSignUp ? '已有账号？登录' : '没有账号？注册')

    const page = h('div', { className: 'auth-page' },
      h('div', { className: 'auth-brand' },
        h('div', { className: 'auth-logo' },
          createLucideIcon('activity', { size: 28, strokeWidth: 2, color: 'white' })
        ),
        h('h1', { className: 'auth-title' }, '脉冲'),
        h('p', { className: 'auth-subtitle' }, 'AI 驱动的生活节律协调助手')
      ),
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
    h('div', { className: 'auth-brand' },
      h('div', { className: 'auth-logo' },
        createLucideIcon('activity', { size: 28, strokeWidth: 2, color: 'white' })
      ),
      h('h1', { className: 'auth-title' }, '脉冲'),
      h('p', { className: 'auth-subtitle' }, 'AI 驱动的生活节律协调助手')
    ),
    h('span', { className: 'demo-badge' }, '演示模式'),
    h('div', { className: 'auth-form' },
      h('button', {
        className: 'btn btn-primary',
        onClick: () => {
          const user = {
            id: crypto.randomUUID(),
            email: 'demo@maichong.app',
            user_metadata: { display_name: '演示用户' }
          }
          store.setState({ user })
          navigate('/')
        }
      }, '开始体验')
    )
  )
  container.appendChild(page)
  return { unmount() {} }
}
