import { h, clearChildren } from '../lib/dom.js'
import { navigate } from '../router.js'
import { createHeader } from '../components/header.js'
import { createShareCard, generateAndDownload } from '../services/share.service.js'
import { showToast } from '../components/toast.js'

export function showSharePreviewView(timelineId, container) {
  clearChildren(container)

  const view = h('div', { className: 'view', style: { position: 'relative' } })

  const header = createHeader({
    title: '分享预览',
    left: [{ icon: 'back', label: '返回', onClick: () => navigate(`/timeline/${timelineId}`) }]
  })
  view.appendChild(header)

  const body = h('div', { className: 'share-preview-page view-body' })

  // 渲染分享卡片预览
  const card = createShareCard()
  card.style.boxShadow = 'var(--shadow-lg)'
  body.appendChild(card)

  // 操作按钮
  const actions = h('div', { className: 'share-actions' },
    h('button', {
      className: 'btn btn-primary',
      onClick: async () => {
        showToast('正在生成图片...', 'info')
        const result = await generateAndDownload()
        if (result) {
          showToast('图片已保存', 'success')
        } else {
          showToast('生成失败，请稍后重试', 'error')
        }
      }
    }, '保存图片'),
    h('button', {
      className: 'btn btn-secondary',
      onClick: () => {
        const link = window.location.href.replace('/share', '')
        navigator.clipboard?.writeText(link)
          .then(() => showToast('链接已复制', 'success'))
          .catch(() => showToast('复制失败', 'error'))
      }
    }, '复制链接')
  )
  body.appendChild(actions)

  view.appendChild(body)
  container.appendChild(view)

  return { unmount() {} }
}
