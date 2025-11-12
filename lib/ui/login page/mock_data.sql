-- ========================================
-- MOCK DATA SQL SCRIPT FOR EPHOR
-- ========================================
-- This script creates test/mock employee data for Supabase
-- Run this in Supabase SQL Editor: SQL Editor → New Query

-- ========================================
-- ⚠️ IMPORTANT: PASSWORDS MUST BE ADDED FIRST! ⚠️
-- ========================================
-- You CANNOT add passwords via SQL in Supabase.
-- You MUST create auth users through the Dashboard or API first.
--
-- QUICK SETUP:
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. For EACH user below:
--    - Click "Add user" → "Create new user"
--    - Email: (use email from mock data below)
--    - Password: "TestPassword123!" (or your choice)
--    - ✅ Auto Confirm User: ON
--    - Click "Create user"
--    - Copy the User ID (UUID) that appears
-- 3. Replace all placeholder UUIDs in this script with actual UUIDs
-- 4. Run this SQL script
--
-- See HOW_TO_ADD_PASSWORDS.md for detailed instructions

-- ========================================
-- STEP 1: Update Table Constraint (if needed)
-- ========================================
ALTER TABLE public.employees 
DROP CONSTRAINT IF EXISTS employees_role_check;

ALTER TABLE public.employees 
ADD CONSTRAINT employees_role_check 
CHECK (role IN ('Supervisor', 'Human Resources'));

-- ========================================
-- STEP 2: Create Mock Employee Data
-- ========================================
-- ⚠️ REMEMBER: Create auth users FIRST (see instructions above) ⚠️
-- Replace all placeholder UUIDs ('00000000-...') with actual UUIDs from auth users

-- Mock Employees with "Supervisor" role
INSERT INTO public.employees (
  id,
  employee_code,
  email,
  first_name,
  last_name,
  role
) VALUES
-- Supervisor 1 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000001', 'SUP001', 'john.supervisor@ephor.com', 'John', 'Mitchell', 'Supervisor'),
-- Supervisor 2 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000002', 'SUP002', 'sarah.chen@ephor.com', 'Sarah', 'Chen', 'Supervisor'),
-- Supervisor 3 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000003', 'SUP003', 'michael.rodriguez@ephor.com', 'Michael', 'Rodriguez', 'Supervisor'),
-- Supervisor 4 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000004', 'SUP004', 'emily.johnson@ephor.com', 'Emily', 'Johnson', 'Supervisor'),
-- Supervisor 5 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000005', 'SUP005', 'david.williams@ephor.com', 'David', 'Williams', 'Supervisor')
ON CONFLICT (id) DO NOTHING;

-- Mock Employees with "Human Resources" role
INSERT INTO public.employees (
  id,
  employee_code,
  email,
  first_name,
  last_name,
  role
) VALUES
-- HR 1 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000010', 'HR001', 'jennifer.martinez@ephor.com', 'Jennifer', 'Martinez', 'Human Resources'),
-- HR 2 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000011', 'HR002', 'robert.taylor@ephor.com', 'Robert', 'Taylor', 'Human Resources'),
-- HR 3 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000012', 'HR003', 'lisa.anderson@ephor.com', 'Lisa', 'Anderson', 'Human Resources'),
-- HR 4 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000013', 'HR004', 'james.wilson@ephor.com', 'James', 'Wilson', 'Human Resources'),
-- HR 5 - Replace UUID with actual auth user UUID
('00000000-0000-0000-0000-000000000014', 'HR005', 'amanda.davis@ephor.com', 'Amanda', 'Davis', 'Human Resources')
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- ALTERNATIVE: Helper Function to Create Users
-- ========================================
-- If you have admin/service_role access, you can use this function to create auth users
-- WARNING: This requires service_role key - use with caution!

CREATE OR REPLACE FUNCTION create_auth_user_and_employee(
  p_email TEXT,
  p_password TEXT,
  p_employee_code TEXT,
  p_first_name TEXT,
  p_last_name TEXT,
  p_role TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Create auth user (requires service_role)
  -- Note: This is a simplified version - actual implementation may vary
  -- For production, create users via Supabase Dashboard or API
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_superadmin,
    confirmation_token,
    recovery_token
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000', -- instance_id (replace with your instance)
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    p_email,
    crypt(p_password, gen_salt('bf')), -- This won't work exactly - Supabase uses different encryption
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    false,
    '',
    ''
  )
  RETURNING id INTO v_user_id;

  -- Create employee record
  INSERT INTO public.employees (
    id,
    employee_code,
    email,
    first_name,
    last_name,
    role
  )
  VALUES (
    v_user_id,
    p_employee_code,
    p_email,
    p_first_name,
    p_last_name,
    p_role
  );

  RETURN v_user_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error creating user: %', SQLERRM;
END;
$$;

-- ========================================
-- RECOMMENDED: Manual User Creation Instructions
-- ========================================
-- 
-- For each employee above, do the following:
--
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add user" → "Create new user"
-- 3. Enter:
--    - Email: (from the INSERT statement above)
--    - Password: "TestPassword123!" (or any password you prefer)
--    - ✅ Auto Confirm User: ON (for testing)
-- 4. Click "Create user"
-- 5. Copy the User ID (UUID) that appears
-- 6. Replace the placeholder UUID in the INSERT statement with the real UUID
-- 7. Run the INSERT statement again
--
-- Example:
--   Email: john.supervisor@ephor.com
--   Password: TestPassword123!
--   User ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
--   Replace: '00000000-0000-0000-0000-000000000001' with 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

-- ========================================
-- QUICK REFERENCE: Employee Codes & Emails
-- ========================================
--
-- SUPERVISORS:
--   SUP001 - john.supervisor@ephor.com
--   SUP002 - sarah.chen@ephor.com
--   SUP003 - michael.rodriguez@ephor.com
--   SUP004 - emily.johnson@ephor.com
--   SUP005 - david.williams@ephor.com
--
-- HUMAN RESOURCES:
--   HR001 - jennifer.martinez@ephor.com
--   HR002 - robert.taylor@ephor.com
--   HR003 - lisa.anderson@ephor.com
--   HR004 - james.wilson@ephor.com
--   HR005 - amanda.davis@ephor.com
--
-- TEST PASSWORD (recommended): TestPassword123!

-- ========================================
-- VERIFICATION QUERIES
-- ========================================

-- Check all employees
SELECT 
  employee_code,
  email,
  first_name,
  last_name,
  role,
  created_at
FROM public.employees
ORDER BY role, employee_code;

-- Count employees by role
SELECT 
  role,
  COUNT(*) as count
FROM public.employees
GROUP BY role;

-- Check if any employees are missing auth users
SELECT 
  e.employee_code,
  e.email,
  e.role,
  CASE 
    WHEN a.id IS NULL THEN 'Missing Auth User'
    ELSE 'OK'
  END as status
FROM public.employees e
LEFT JOIN auth.users a ON e.id = a.id
ORDER BY e.role, e.employee_code;

-- ========================================
-- CLEANUP (if needed)
-- ========================================
-- Uncomment to remove all mock data:

-- DELETE FROM public.employees WHERE employee_code LIKE 'SUP%' OR employee_code LIKE 'HR%';

