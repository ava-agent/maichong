export const config = {
  supabaseUrl: import.meta.env.VITE_SUPABASE_URL || '',
  supabaseAnonKey: import.meta.env.VITE_SUPABASE_ANON_KEY || '',
  aiChatEndpoint: import.meta.env.VITE_AI_CHAT_ENDPOINT || '/api/chat',
}
