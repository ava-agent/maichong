import { createClient } from '@supabase/supabase-js'
import { config } from '../config.js'

let supabase = null

export function getSupabase() {
  if (!supabase && config.supabaseUrl && config.supabaseAnonKey) {
    supabase = createClient(config.supabaseUrl, config.supabaseAnonKey)
  }
  return supabase
}

export function isSupabaseConfigured() {
  return !!(config.supabaseUrl && config.supabaseAnonKey)
}
