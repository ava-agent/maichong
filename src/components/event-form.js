import { h } from '../lib/dom.js'
import { showModal } from './modal.js'

/**
 * 显示事件创建/编辑表单
 * @param {Object} event - 已有事件数据（编辑模式），null 为新建
 * @param {Function} onSave - 保存回调 (data) => void
 * @param {Function} onDelete - 删除回调 (id) => void（仅编辑模式）
 */
export function showEventForm(event = null, { onSave, onDelete } = {}) {
  const isEdit = !!event
  const today = new Date().toISOString().slice(0, 10)

  const form = h('form', { className: 'event-form' },
    // 标题
    h('div', { className: 'form-group' },
      h('label', { className: 'form-label' }, '标题'),
      h('input', {
        className: 'form-input',
        type: 'text',
        name: 'title',
        placeholder: '活动名称',
        value: event?.title || '',
        required: 'true',
      })
    ),
    // 日期
    h('div', { className: 'form-group' },
      h('label', { className: 'form-label' }, '日期'),
      h('input', {
        className: 'form-input',
        type: 'date',
        name: 'event_date',
        value: event?.event_date || today,
      })
    ),
    // 全天开关
    h('div', { className: 'form-group toggle-wrap' },
      h('label', { className: 'form-label', style: { margin: '0' } }, '全天'),
      h('input', {
        className: 'toggle',
        type: 'checkbox',
        name: 'is_all_day',
        ...(event?.is_all_day ? { checked: 'true' } : {})
      })
    ),
    // 时间行
    h('div', { className: 'form-row time-row' },
      h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '开始时间'),
        h('input', {
          className: 'form-input',
          type: 'time',
          name: 'start_time',
          value: event?.start_time?.slice(0, 5) || '10:00',
        })
      ),
      h('div', { className: 'form-group' },
        h('label', { className: 'form-label' }, '结束时间'),
        h('input', {
          className: 'form-input',
          type: 'time',
          name: 'end_time',
          value: event?.end_time?.slice(0, 5) || '',
        })
      )
    ),
    // 描述
    h('div', { className: 'form-group' },
      h('label', { className: 'form-label' }, '描述（可选）'),
      h('textarea', {
        className: 'form-input form-textarea',
        name: 'description',
        placeholder: '添加更多细节...',
        rows: '3',
      }, event?.description || '')
    ),
    // 按钮
    h('div', { className: 'flex flex-col gap-8' },
      h('button', { className: 'btn btn-primary', type: 'submit' },
        isEdit ? '保存修改' : '创建事件'
      ),
      isEdit && onDelete
        ? h('button', {
            className: 'btn btn-danger w-full',
            type: 'button',
            onClick: () => {
              onDelete(event.id)
              modal.close()
            }
          }, '删除事件')
        : null
    )
  )

  // 全天开关联动
  const allDayToggle = form.querySelector('[name="is_all_day"]')
  const timeRow = form.querySelector('.time-row')
  function updateTimeRow() {
    timeRow.style.display = allDayToggle.checked ? 'none' : 'flex'
  }
  allDayToggle.addEventListener('change', updateTimeRow)
  updateTimeRow()

  // 表单提交
  form.addEventListener('submit', (e) => {
    e.preventDefault()
    const formData = new FormData(form)
    const data = {
      title: formData.get('title')?.trim(),
      event_date: formData.get('event_date'),
      is_all_day: allDayToggle.checked,
      start_time: allDayToggle.checked ? null : (formData.get('start_time') || null),
      end_time: allDayToggle.checked ? null : (formData.get('end_time') || null),
      description: formData.get('description')?.trim() || '',
    }

    if (!data.title) {
      form.querySelector('[name="title"]').focus()
      return
    }

    onSave?.(data)
    modal.close()
  })

  const modal = showModal(isEdit ? '编辑事件' : '新建事件', form)
  // 自动聚焦标题
  setTimeout(() => form.querySelector('[name="title"]').focus(), 100)

  return modal
}
