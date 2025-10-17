import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { employee_code, password } = await req.json()
    if (!employee_code || !password) {
      throw new Error('Employee code and password are required.')
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: employee, error: employeeError } = await supabaseAdmin
      .from('employees')
      .select('email')
      .eq('employee_code', employee_code)
      .single()

    if (employeeError || !employee) {
      throw new Error('Invalid employee code.')
    }

    const { data: sessionData, error: signInError } = await supabaseAdmin.auth.signInWithPassword({
      email: employee.email,
      password: password,
    })

    if (signInError) {
      throw signInError
    }

    return new Response(JSON.stringify(sessionData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})