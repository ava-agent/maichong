import { h } from '../lib/dom.js'

const COLORS = [
  '#4C6EF5',
  '#00B578',
  '#FF8800',
  '#FA5151',
  '#7048E8',
  '#0CA678',
]

export function createAvatarStack(members, maxShow = 3) {
  const shown = members.slice(0, maxShow)
  const extra = members.length - maxShow

  const avatars = shown.map((member, i) => {
    const name = member.profile?.display_name || member.display_name || '?'
    const initial = name.charAt(0).toUpperCase()

    return h('div', {
      className: 'avatar',
      style: { background: COLORS[i % COLORS.length], color: '#fff' },
      title: name
    }, initial)
  })

  if (extra > 0) {
    avatars.push(h('div', { className: 'avatar avatar-more' }, `+${extra}`))
  }

  return h('div', { className: 'participants' }, ...avatars)
}
