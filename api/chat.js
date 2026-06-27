const DEFAULT_ARK_BASE_URL = 'https://ark.cn-beijing.volces.com/api/coding/v3'
const DEFAULT_ARK_CHAT_MODEL = 'doubao-seed-2-0-code-preview-260215'

function readEnv(name, fallback = '') {
  const value = process.env[name]?.trim()
  return value && value.length > 0 ? value : fallback
}

function chatCompletionsUrl(baseUrl) {
  const normalized = baseUrl.replace(/\/+$/, '')
  return normalized.endsWith('/chat/completions')
    ? normalized
    : `${normalized}/chat/completions`
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST')
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const apiKey = readEnv('ARK_API_KEY')
  if (!apiKey) {
    return res.status(500).json({ error: 'ARK_API_KEY is not configured' })
  }

  const { messages, temperature = 0.7 } = req.body || {}
  if (!Array.isArray(messages) || messages.length === 0) {
    return res.status(400).json({ error: 'messages must be a non-empty array' })
  }

  try {
    const arkResponse = await fetch(
      chatCompletionsUrl(readEnv('ARK_BASE_URL', DEFAULT_ARK_BASE_URL)),
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: readEnv('ARK_CHAT_MODEL', DEFAULT_ARK_CHAT_MODEL),
          messages,
          temperature,
        }),
      }
    )

    const data = await arkResponse.json().catch(() => ({}))

    if (!arkResponse.ok) {
      return res.status(arkResponse.status).json({
        error: data.error?.message || data.message || 'Ark API request failed',
      })
    }

    return res.status(200).json({
      content: data.choices?.[0]?.message?.content || '',
      usage: data.usage || null,
    })
  } catch (error) {
    return res.status(500).json({
      error: error instanceof Error ? error.message : 'Ark API request failed',
    })
  }
}
