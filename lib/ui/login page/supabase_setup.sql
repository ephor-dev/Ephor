-- ========================================
-- SUPABASE SETUP SQL SCRIPT FOR EPHOR
-- ========================================
-- Run this in Supabase SQL Editor
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql/new

-- Step 1: Create employees table
CREATE TABLE IF NOT EXISTS public.employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_code TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('employee', 'hr')),
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_employees_employee_code ON public.employees(employee_code);
CREATE INDEX IF NOT EXISTS idx_employees_email ON public.employees(email);

-- Step 3: Create function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Create trigger for updated_at
CREATE TRIGGER update_employees_updated_at
  BEFORE UPDATE ON public.employees
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 5: Enable Row Level Security
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

-- Step 6: RLS Policies
-- Policy: Authenticated users can read their own data
CREATE POLICY "Users can read own employee data"
  ON public.employees
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Policy: Allow anonymous users to read employee_code and email (for login)
-- ⚠️ SECURITY NOTE: This allows public read access. Consider using a function instead for production.
CREATE POLICY "Public can read for login lookup"
  ON public.employees
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Policy: Service role can do everything (for admin operations)
CREATE POLICY "Service role full access"
  ON public.employees
  FOR ALL
  TO service_role
  USING (true);

-- ========================================
-- TEST DATA (Optional - Remove in production)
-- ========================================
-- Note: You must create auth users first via Supabase Dashboard
-- Authentication → Users → Add user

-- Example: After creating auth user with email 'test@example.com' and UUID 'xxx-xxx-xxx',
-- uncomment and run this (replace UUID with actual auth user UUID):

/*
INSERT INTO public.employees (
  id,
  employee_code,
  email,
  first_name,
  last_name,
  role
)
VALUES (
  'REPLACE_WITH_AUTH_USER_UUID',  -- Get from Authentication → Users
  'TEST001',
  'test@example.com',              -- Must match auth.users.email
  'Test',
  'User',
  'employee'
);
*/

-- ========================================
-- VERIFICATION QUERIES (Run to check setup)
-- ========================================

-- Check if table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'employees';

-- Check table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'employees'
ORDER BY ordinal_position;

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Check policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'employees';
