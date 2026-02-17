/**
 * 组件基类 — 提供 mount/unmount/render 生命周期
 */
export class Component {
  constructor(props = {}) {
    this.props = props
    this.el = null
    this._unsubscribers = []
  }

  /** 子类重写：返回 DOM 节点 */
  render() {
    throw new Error('Component.render() must be implemented')
  }

  /** 挂载到容器 */
  mount(container) {
    this.el = this.render()
    container.appendChild(this.el)
    this.onMount()
    return this
  }

  /** 替换现有内容后挂载 */
  mountReplace(container) {
    while (container.firstChild) container.removeChild(container.firstChild)
    return this.mount(container)
  }

  /** 卸载 */
  unmount() {
    this.onUnmount()
    this._unsubscribers.forEach(fn => fn())
    this._unsubscribers = []
    if (this.el && this.el.parentNode) {
      this.el.parentNode.removeChild(this.el)
    }
    this.el = null
  }

  /** 生命周期钩子 */
  onMount() {}
  onUnmount() {}

  /** 注册 store 订阅（卸载时自动清理） */
  addUnsubscriber(fn) {
    this._unsubscribers.push(fn)
  }
}
