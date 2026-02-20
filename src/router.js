/**
 * 简易 Hash 路由
 */
const routes = []
let currentView = null
let viewContainer = null
let beforeEachGuard = null
let isNavigating = false

export function setViewContainer(container) {
  viewContainer = container
}

export function addRoute(pattern, handler) {
  // 将 :param 转换为正则捕获组
  const regex = new RegExp('^' + pattern.replace(/:(\w+)/g, '(?<$1>[^/]+)') + '$')
  routes.push({ pattern, regex, handler })
}

export function beforeEach(guard) {
  beforeEachGuard = guard
}

export function navigate(path) {
  window.location.hash = path
}

export function getCurrentPath() {
  return window.location.hash.slice(1) || '/'
}

function matchRoute(path) {
  for (const route of routes) {
    const match = path.match(route.regex)
    if (match) {
      return { handler: route.handler, params: match.groups || {} }
    }
  }
  return null
}

async function handleRouteChange() {
  if (isNavigating) return
  isNavigating = true

  try {
    const path = getCurrentPath()

    // 执行路由守卫
    if (beforeEachGuard) {
      const result = await beforeEachGuard(path)
      if (result === false) return
      if (typeof result === 'string') {
        navigate(result)
        return
      }
    }

    const matched = matchRoute(path)
    if (!matched) {
      // Fallback to home; if already at home, do nothing to prevent loops
      if (path !== '/') navigate('/')
      return
    }

    // 卸载旧视图
    if (currentView && currentView.unmount) {
      currentView.unmount()
    }

    // 挂载新视图
    if (viewContainer) {
      currentView = await matched.handler(matched.params, viewContainer)
    }
  } finally {
    isNavigating = false
  }
}

export function initRouter() {
  window.addEventListener('hashchange', handleRouteChange)
  // 初始路由
  handleRouteChange()
}
