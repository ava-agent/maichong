export const config = {
  supabaseUrl: import.meta.env.VITE_SUPABASE_URL || '',
  supabaseAnonKey: import.meta.env.VITE_SUPABASE_ANON_KEY || '',
  glm4ApiKey: import.meta.env.VITE_GLM4_API_KEY || '',
  glm4Endpoint: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
  glm4Model: 'glm-4',
}
