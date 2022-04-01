import { createClient } from '@supabase/supabase-js'
import { RealtimeClient } from '@supabase/realtime-js'

const SUPABASE_URL = ''
const SUPABASE_ANON_KEY = ''

const REALTIME_URL = ''
const REALTIME_ANON_KEY = ''

const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

const realtimeClient = new RealtimeClient(REALTIME_URL, {
  params: {
    apikey: REALTIME_ANON_KEY,
  },
})
realtimeClient.setAuth(REALTIME_ANON_KEY)

export { supabaseClient, realtimeClient }
