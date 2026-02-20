import { store } from '../lib/store.js'
import { h } from '../lib/dom.js'
import { groupEventsByDate, formatDateLabel, formatTime } from './event.service.js'

/**
 * 生成分享卡片 DOM 节点
 */
export function createShareCard() {
  const timeline = store.getState().currentTimeline
  const events = store.getState().events
  const groups = groupEventsByDate(events)

  const card = h('div', { className: 'share-card' },
    // 头部
    h('div', { className: 'share-header' },
      h('h1', { className: 'share-title' }, timeline?.title || '我的时间线'),
      h('p', { className: 'share-date' }, getDateRange(events))
    ),
    // 时间线内容
    h('div', { className: 'share-timeline' },
      ...Array.from(groups.entries()).flatMap(([date, items]) => [
        h('div', { className: 'share-date-label' }, formatDateLabel(date)),
        ...items.map(event =>
          h('div', { className: 'share-event' },
            h('div', { className: 'event-time' }, formatTime(event.start_time)),
            h('div', { className: 'event-details' },
              h('h2', { className: 'event-title' }, event.title),
              event.description ? h('p', { className: 'event-note' }, event.description) : null
            )
          )
        )
      ])
    ),
    // 底部品牌
    h('div', { className: 'share-footer' },
      h('div', { className: 'share-logo' },
        h('span', { className: 'logo-icon' }, '\u8109'),
        h('span', {}, '\u8109\u51b2')
      ),
      h('p', { className: 'share-slogan' }, '同步每次脉冲。')
    )
  )

  return card
}

function getDateRange(events) {
  if (events.length === 0) return ''
  const dates = events.map(e => e.event_date).sort()
  const start = new Date(dates[0] + 'T00:00:00')
  const end = new Date(dates[dates.length - 1] + 'T00:00:00')

  const fmt = (d) => new Intl.DateTimeFormat('zh-CN', { year: 'numeric', month: 'long', day: 'numeric' }).format(d)

  if (dates[0] === dates[dates.length - 1]) return fmt(start)
  return `${fmt(start)} - ${fmt(end)}`
}

/**
 * 生成截图并下载
 */
export async function generateAndDownload() {
  const card = createShareCard()
  // 临时挂载到 body 以便截图
  card.style.position = 'fixed'
  card.style.left = '-9999px'
  card.style.top = '0'
  document.body.appendChild(card)

  try {
    const { domToPng } = await import('modern-screenshot')
    const dataUrl = await domToPng(card, { scale: 2 })

    // 下载
    const link = document.createElement('a')
    link.download = `脉冲-${store.getState().currentTimeline?.title || '分享'}.png`
    link.href = dataUrl
    link.click()

    return dataUrl
  } catch (err) {
    // fallback: 尝试使用 Web Share API
    console.error('截图生成失败:', err)
    return null
  } finally {
    if (card.parentNode) card.parentNode.removeChild(card)
  }
}

/**
 * 通过 Web Share API 分享
 */
export async function shareViaWebAPI(dataUrl) {
  if (!navigator.share) return false

  try {
    const blob = await (await fetch(dataUrl)).blob()
    const file = new File([blob], '脉冲分享.png', { type: 'image/png' })
    await navigator.share({
      title: store.getState().currentTimeline?.title || '脉冲',
      text: '来看看我们的计划吧！',
      files: [file]
    })
    return true
  } catch {
    return false
  }
}
