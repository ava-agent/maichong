import createElement from 'lucide/dist/esm/createElement.js'

// Individual icon imports for tree-shaking
import House from 'lucide/dist/esm/icons/house.js'
import CalendarDays from 'lucide/dist/esm/icons/calendar-days.js'
import MessageCircle from 'lucide/dist/esm/icons/message-circle.js'
import User from 'lucide/dist/esm/icons/user.js'
import ArrowLeft from 'lucide/dist/esm/icons/arrow-left.js'
import Share2 from 'lucide/dist/esm/icons/share-2.js'
import Plus from 'lucide/dist/esm/icons/plus.js'
import Trash2 from 'lucide/dist/esm/icons/trash-2.js'
import EllipsisVertical from 'lucide/dist/esm/icons/ellipsis-vertical.js'
import UserPlus from 'lucide/dist/esm/icons/user-plus.js'
import LogOut from 'lucide/dist/esm/icons/log-out.js'
import Copy from 'lucide/dist/esm/icons/copy.js'
import SendHorizontal from 'lucide/dist/esm/icons/send-horizontal.js'
import Search from 'lucide/dist/esm/icons/search.js'
import Clock from 'lucide/dist/esm/icons/clock.js'
import CircleCheck from 'lucide/dist/esm/icons/circle-check.js'
import ChevronRight from 'lucide/dist/esm/icons/chevron-right.js'
import Activity from 'lucide/dist/esm/icons/activity.js'
import Info from 'lucide/dist/esm/icons/info.js'
import Settings from 'lucide/dist/esm/icons/settings.js'

const ICON_DATA = {
  house: House,
  'calendar-days': CalendarDays,
  'message-circle': MessageCircle,
  user: User,
  'arrow-left': ArrowLeft,
  'share-2': Share2,
  plus: Plus,
  'trash-2': Trash2,
  'ellipsis-vertical': EllipsisVertical,
  'user-plus': UserPlus,
  'log-out': LogOut,
  copy: Copy,
  'send-horizontal': SendHorizontal,
  search: Search,
  clock: Clock,
  'circle-check': CircleCheck,
  'chevron-right': ChevronRight,
  activity: Activity,
  info: Info,
  settings: Settings,
}

/**
 * Create a Lucide SVG icon element
 * @param {string} name - Icon name (kebab-case)
 * @param {object} options - { size, strokeWidth, color, className }
 * @returns {SVGElement}
 */
export function createLucideIcon(name, { size = 22, strokeWidth = 1.75, color, className } = {}) {
  const iconData = ICON_DATA[name]
  if (!iconData) {
    const span = document.createElement('span')
    span.textContent = '?'
    return span
  }

  const attrs = {
    width: size,
    height: size,
    'stroke-width': strokeWidth,
  }
  if (color) attrs.stroke = color
  if (className) attrs.class = className

  return createElement(iconData, attrs)
}
