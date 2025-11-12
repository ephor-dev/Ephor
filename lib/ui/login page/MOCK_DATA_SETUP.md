# Mock Data Setup Guide

## Quick Start

This guide will help you create test/mock employee data in Supabase with **"Supervisor"** and **"Human Resources"** roles.

## Step-by-Step Instructions

### Step 1: Update Table Constraint (If Needed)

If your `employees` table was created with old role constraints, update it:

```sql
ALTER TABLE public.employees 
DROP CONSTRAINT IF EXISTS employees_role_check;

ALTER TABLE public.employees 
ADD CONSTRAINT employees_role_check 
CHECK (role IN ('Supervisor', 'Human Resources'));
```

### Step 2: Create Auth Users

**For each employee**, you need to create a corresponding auth user:

1. Go to **Supabase Dashboard** → **Authentication** → **Users**
2. Click **"Add user"** → **"Create new user"**
3. Fill in:
   - **Email**: Use the email from the mock data (e.g., `john.supervisor@ephor.com`)
   - **Password**: `TestPassword123!` (or any password)
   - **Auto Confirm User**: ✅ ON (for testing)
4. Click **"Create user"**
5. **Copy the User ID (UUID)** that appears

### Step 3: Insert Employee Records

1. Open the SQL script: `mock_data.sql`
2. For each employee, replace the placeholder UUID with the actual UUID from Step 2
3. Run the INSERT statements

**Example:**
- Created auth user: `john.supervisor@ephor.com` with UUID: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`
- In the SQL script, replace:
  ```sql
  ('00000000-0000-0000-0000-000000000001', 'SUP001', 'john.supervisor@ephor.com', ...)
  ```
  with:
  ```sql
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'SUP001', 'john.supervisor@ephor.com', ...)
  ```

## Mock Data Overview

### Supervisors (5 employees)
- **SUP001** - John Mitchell - john.supervisor@ephor.com
- **SUP002** - Sarah Chen - sarah.chen@ephor.com
- **SUP003** - Michael Rodriguez - michael.rodriguez@ephor.com
- **SUP004** - Emily Johnson - emily.johnson@ephor.com
- **SUP005** - David Williams - david.williams@ephor.com

### Human Resources (5 employees)
- **HR001** - Jennifer Martinez - jennifer.martinez@ephor.com
- **HR002** - Robert Taylor - robert.taylor@ephor.com
- **HR003** - Lisa Anderson - lisa.anderson@ephor.com
- **HR004** - James Wilson - james.wilson@ephor.com
- **HR005** - Amanda Davis - amanda.davis@ephor.com

## Testing Login

After setting up the mock data, test login with:

### Supervisor Login Example:
- **Employee Code**: `SUP001`
- **Password**: `TestPassword123!`
- **Role**: Select "Supervisor" (or "Human Resources" if using HR code)

### Human Resources Login Example:
- **Employee Code**: `HR001`
- **Password**: `TestPassword123!`
- **Role**: Select "Human Resources"

## Quick Verification

Run this SQL query to verify your setup:

```sql
SELECT 
  employee_code,
  email,
  first_name || ' ' || last_name as full_name,
  role,
  CASE 
    WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = employees.id) 
    THEN '✅ Auth User Exists' 
    ELSE '❌ Missing Auth User' 
  END as status
FROM public.employees
ORDER BY role, employee_code;
```

All rows should show "✅ Auth User Exists".

## Troubleshooting

### "Employee code not found"
- Verify the employee_code exists in the employees table
- Check exact spelling and casing

### "Invalid login credentials"
- Ensure the email in `employees` table matches the email in `auth.users`
- Verify the password is correct
- Check that the auth user was created successfully

### "Invalid role for this employee"
- Ensure the role in database matches: "Supervisor" or "Human Resources"
- Note: These are case-sensitive!

## Notes

- **Password**: Recommended test password is `TestPassword123!`
- **Email Matching**: The email in `employees` table MUST match the email in `auth.users`
- **ID Matching**: The `employees.id` MUST match `auth.users.id` (use the UUID from auth user creation)
- **Role Values**: Only "Supervisor" and "Human Resources" are valid (case-sensitive)

