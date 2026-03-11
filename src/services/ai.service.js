import { config } from '../config.js'
import { store } from '../lib/store.js'
import { getSupabase, isSupabaseConfigured } from '../lib/supabase.js'
import { createEvent, updateEvent, deleteEvent } from './event.service.js'

function buildSystemPrompt(timeline, events) {
  const today = new Date().toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })
  const eventsSummary = events.length > 0
    ? events.map(e => `- ${e.event_date} ${e.start_time || '全天'} | ${e.title}${e.description ? ' (' + e.description + ')' : ''} [ID:${e.id}]`).join('\n')
    : '暂无事件'

  return `你是"脉冲"的AI助手，帮助用户管理时间线"${timeline?.title || '我的时间线'}"。
今天是${today}。

当前时间线已有事件：
${eventsSummary}

用户可能会：
1. 用自然语言描述一个新活动 → 提取结构化信息并创建事件
2. 要求修改或删除现有事件
3. 询问日程安排相关的问题

请始终返回JSON格式：
{
  "reply": "你的自然语言回复（简洁友好）",
  "action": null 或 {
    "type": "create_event" 或 "update_event" 或 "delete_event",
    "data": {
      "title": "事件标题",
      "description": "描述（可选）",
      "event_date": "YYYY-MM-DD",
      "start_time": "HH:MM" 或 null,
      "end_time": "HH:MM" 或 null,
      "is_all_day": boolean
    },
    "event_id": "仅在update/delete时提供已有事件ID"
  }
}

如果不涉及事件操作，action设为null。
日期推断：如果用户说"这周六"，请根据今天日期推算。
回复使用中文。`
}

export async function sendChatMessage(timelineId, userMessage) {
  const timeline = store.getState().currentTimeline
  const events = store.getState().events
  const chatMessages = store.getState().chatMessages

  // 保存用户消息
  const userMsg = {
    id: crypto.randomUUID(),
    timeline_id: timelineId,
    user_id: store.getState().user?.id,
    role: 'user',
    content: userMessage,
    created_at: new Date().toISOString()
  }
  store.setState({ chatMessages: [...chatMessages, userMsg] })

  // 持久化用户消息
  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    await supabase.from('chat_messages').insert({
      timeline_id: timelineId,
      user_id: store.getState().user?.id,
      role: 'user',
      content: userMessage
    })
  } else {
    saveLocalChatMessages(timelineId, store.getState().chatMessages)
  }

  // 调用 AI
  const systemPrompt = buildSystemPrompt(timeline, events)
  const recentHistory = store.getState().chatMessages.slice(-10).map(m => ({
    role: m.role === 'assistant' ? 'assistant' : 'user',
    content: m.content
  }))

  const messages = [
    { role: 'system', content: systemPrompt },
    ...recentHistory
  ]

  let aiReply, aiAction

  if (config.glm4ApiKey) {
    try {
      const response = await fetch(config.glm4Endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${config.glm4ApiKey}`
        },
        body: JSON.stringify({
          model: config.glm4Model,
          messages,
          temperature: 0.7,
        })
      })

      const data = await response.json()
      const content = data.choices?.[0]?.message?.content || ''

      // 尝试解析 JSON
      try {
        const parsed = JSON.parse(content)
        aiReply = parsed.reply || content
        aiAction = parsed.action || null
      } catch {
        // 如果不是 JSON，直接使用文本
        aiReply = content
        aiAction = null
      }
    } catch (err) {
      aiReply = '抱歉，AI 服务暂时不可用，请稍后再试。'
      aiAction = null
    }
  } else {
    // 无 API Key 时使用模拟响应
    const mockResult = generateMockResponse(userMessage)
    aiReply = mockResult.reply
    aiAction = mockResult.action
  }

  // 保存 AI 回复
  const aiMsg = {
    id: crypto.randomUUID(),
    timeline_id: timelineId,
    user_id: store.getState().user?.id,
    role: 'assistant',
    content: aiReply,
    metadata: aiAction ? { action: aiAction } : {},
    created_at: new Date().toISOString()
  }
  store.setState({ chatMessages: [...store.getState().chatMessages, aiMsg] })

  if (isSupabaseConfigured()) {
    const supabase = getSupabase()
    await supabase.from('chat_messages').insert({
      timeline_id: timelineId,
      user_id: store.getState().user?.id,
      role: 'assistant',
      content: aiReply,
      metadata: aiAction ? { action: aiAction } : {}
    })
  } else {
    saveLocalChatMessages(timelineId, store.getState().chatMessages)
  }

  // 执行 AI 操作
  if (aiAction) {
    await executeAiAction(timelineId, aiAction)
  }

  return { reply: aiReply, action: aiAction }
}

async function executeAiAction(timelineId, action) {
  if (action.type === 'create_event') {
    await createEvent(timelineId, action.data)
  } else if (action.type === 'update_event' && action.event_id) {
    await updateEvent(action.event_id, action.data)
  } else if (action.type === 'delete_event' && action.event_id) {
    await deleteEvent(action.event_id)
  }
}

// 本地聊天记录存储
const LOCAL_CHAT_KEY = 'maichong_chat_messages'

function getLocalChatMessages(timelineId) {
  try {
    const all = JSON.parse(localStorage.getItem(LOCAL_CHAT_KEY) || '{}')
    return all[timelineId] || []
  } catch { return [] }
}

function saveLocalChatMessages(timelineId, messages) {
  try {
    const all = JSON.parse(localStorage.getItem(LOCAL_CHAT_KEY) || '{}')
    all[timelineId] = messages.slice(-50) // 保留最近50条
    localStorage.setItem(LOCAL_CHAT_KEY, JSON.stringify(all))
  } catch {}
}

export async function loadChatHistory(timelineId) {
  if (!isSupabaseConfigured()) {
    const messages = getLocalChatMessages(timelineId)
    store.setState({ chatMessages: messages })
    return messages
  }

  const supabase = getSupabase()
  const { data, error } = await supabase
    .from('chat_messages')
    .select('*')
    .eq('timeline_id', timelineId)
    .order('created_at', { ascending: true })
    .limit(50)

  if (error) return []
  store.setState({ chatMessages: data })
  return data
}

/** 无 API Key 时的模拟响应 */
function generateMockResponse(userMessage) {
  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)

  // 简单关键词匹配
  if (userMessage.includes('咖啡') || userMessage.includes('下午茶')) {
    return {
      reply: `好的，已为你安排"下午茶时光 ☕"。`,
      action: {
        type: 'create_event',
        data: {
          title: '下午茶时光 ☕',
          description: userMessage,
          event_date: tomorrow.toISOString().slice(0, 10),
          start_time: '15:00',
          end_time: '16:30',
          is_all_day: false
        }
      }
    }
  }

  if (userMessage.includes('晚餐') || userMessage.includes('吃饭')) {
    return {
      reply: `已安排晚餐活动，时间可以根据需要调整哦。`,
      action: {
        type: 'create_event',
        data: {
          title: '晚餐',
          description: userMessage,
          event_date: tomorrow.toISOString().slice(0, 10),
          start_time: '18:30',
          end_time: '20:00',
          is_all_day: false
        }
      }
    }
  }

  if (userMessage.includes('旅行') || userMessage.includes('出游') || userMessage.includes('出发')) {
    return {
      reply: `好的，已创建出游计划！你可以继续添加更多细节。`,
      action: {
        type: 'create_event',
        data: {
          title: '出游计划',
          description: userMessage,
          event_date: tomorrow.toISOString().slice(0, 10),
          start_time: '09:00',
          end_time: null,
          is_all_day: false
        }
      }
    }
  }

  // 默认回复
  return {
    reply: `收到！我已记录你的计划"${userMessage.slice(0, 20)}"。需要我帮你安排到时间线上吗？`,
    action: {
      type: 'create_event',
      data: {
        title: userMessage.slice(0, 30),
        description: '',
        event_date: tomorrow.toISOString().slice(0, 10),
        start_time: '10:00',
        end_time: null,
        is_all_day: false
      }
    }
  }
}
