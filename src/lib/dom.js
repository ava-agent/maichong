/**
 * DOM 辅助工具
 */

/** 创建元素 */
export function h(tag, attrs = {}, ...children) {
  const el = document.createElement(tag)

  for (const [key, value] of Object.entries(attrs)) {
    if (key === 'className') {
      el.className = value
    } else if (key === 'style' && typeof value === 'object') {
      Object.assign(el.style, value)
    } else if (key.startsWith('on') && typeof value === 'function') {
      el.addEventListener(key.slice(2).toLowerCase(), value)
    } else if (key === 'dataset') {
      Object.assign(el.dataset, value)
    } else if (key === 'innerHTML') {
      el.innerHTML = value
    } else {
      el.setAttribute(key, value)
    }
  }

  for (const child of children.flat()) {
    if (child == null || child === false) continue
    if (typeof child === 'string' || typeof child === 'number') {
      el.appendChild(document.createTextNode(String(child)))
    } else if (child instanceof Node) {
      el.appendChild(child)
    }
  }

  return el
}

/** 清空元素子节点 */
export function clearChildren(el) {
  while (el.firstChild) el.removeChild(el.firstChild)
}

/** 安全地设置 ID 查找 */
export function $(selector) {
  return document.querySelector(selector)
}

export function $$(selector) {
  return document.querySelectorAll(selector)
}
