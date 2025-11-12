# How to Add Passwords for Mock Data

## Important: Passwords Cannot Be Added via SQL

Supabase secures passwords by encrypting them, so you **cannot directly insert passwords via SQL**. You must create auth users through one of these methods:

## Method 1: Supabase Dashboard (Recommended - Easiest)

### Step-by-Step Instructions:

1. **Open Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Navigate to Authentication → Users**
   - Click "Authentication" in the left sidebar
   - Click "Users" tab

3. **Create Users One by One**
   - Click **"Add user"** button (top right)
   - Select **"Create new user"**

4. **Fill in User Details:**
   - **Email**: Enter the email from mock data (e.g., `john.supervisor@ephor.com`)
   - **Password**: Enter `TestPassword123!` (or your preferred password)
   - **✅ Auto Confirm User**: TURN ON (important for testing)
   - Click **"Create user"**

5. **Copy the User ID**
   - After creation, the User ID (UUID) appears
   - Copy this UUID

6. **Repeat for All Users**
   - Create all 10 users (5 Supervisors + 5 HR)
   - Copy each UUID as you create them

### Quick Reference - All Mock Users:

#### Supervisors:
- `john.supervisor@ephor.com` → Copy UUID for SUP001
- `sarah.chen@ephor.com` → Copy UUID for SUP002
- `michael.rodriguez@ephor.com` → Copy UUID for SUP003
- `emily.johnson@ephor.com` → Copy UUID for SUP004
- `david.williams@ephor.com` → Copy UUID for SUP005

#### Human Resources:
- `jennifer.martinez@ephor.com` → Copy UUID for HR001
- `robert.taylor@ephor.com` → Copy UUID for HR002
- `lisa.anderson@ephor.com` → Copy UUID for HR003
- `james.wilson@ephor.com` → Copy UUID for HR004
- `amanda.davis@ephor.com` → Copy UUID for HR005

### Update the SQL Script:

After creating all users and copying their UUIDs, update `mock_data.sql`:

1. Replace each placeholder UUID with the actual UUID you copied
2. Example:
   ```sql
   -- Before:
   ('00000000-0000-0000-0000-000000000001', 'SUP001', 'john.supervisor@ephor.com', ...)
   
   -- After (using actual UUID):
   ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'SUP001', 'john.supervisor@ephor.com', ...)
   ```

3. Run the updated SQL script

---

## Method 2: Supabase Management API (Advanced)

If you want to automate user creation, you can use Supabase's Management API with your service_role key.

### Python Script Example:

```python
import requests
import json

SUPABASE_URL = "https://your-project.supabase.co"
SERVICE_ROLE_KEY = "your-service-role-key"  # Get from Settings → API

headers = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

# List of users to create
users = [
    {"email": "john.supervisor@ephor.com", "password": "TestPassword123!", "employee_code": "SUP001"},
    {"email": "sarah.chen@ephor.com", "password": "TestPassword123!", "employee_code": "SUP002"},
    # ... add all users
]

for user in users:
    # Create auth user
    response = requests.post(
        f"{SUPABASE_URL}/auth/v1/admin/users",
        headers=headers,
        json={
            "email": user["email"],
            "password": user["password"],
            "email_confirm": True,  # Auto-confirm
            "user_metadata": {
                "employee_code": user["employee_code"]
            }
        }
    )
    
    if response.status_code == 200:
        user_data = response.json()
        user_id = user_data["id"]
        print(f"Created user: {user['email']} with ID: {user_id}")
        # Now insert into employees table with this user_id
    else:
        print(f"Error creating {user['email']}: {response.text}")
```

### Node.js/JavaScript Example:

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://your-project.supabase.co';
const serviceRoleKey = 'your-service-role-key'; // Get from Settings → API

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

const users = [
  { email: 'john.supervisor@ephor.com', password: 'TestPassword123!', employee_code: 'SUP001' },
  // ... add all users
];

async function createUsers() {
  for (const user of users) {
    const { data, error } = await supabase.auth.admin.createUser({
      email: user.email,
      password: user.password,
      email_confirm: true, // Auto-confirm
      user_metadata: {
        employee_code: user.employee_code
      }
    });
    
    if (error) {
      console.error(`Error creating ${user.email}:`, error);
    } else {
      console.log(`Created user: ${user.email} with ID: ${data.user.id}`);
      // Now insert into employees table with data.user.id
    }
  }
}

createUsers();
```

---

## Method 3: Bulk Import via CSV (Future Feature)

Supabase may support CSV import in the future. For now, Method 1 (Dashboard) is the most reliable.

---

## Quick Setup Checklist

- [ ] Created all 10 auth users in Dashboard
- [ ] Set password to `TestPassword123!` for all users
- [ ] Enabled "Auto Confirm" for all users
- [ ] Copied all 10 User IDs (UUIDs)
- [ ] Updated `mock_data.sql` with actual UUIDs
- [ ] Ran the SQL script to insert employee records
- [ ] Verified with verification query (see below)

## Verification Query

Run this to check if all users have passwords set:

```sql
SELECT 
  e.employee_code,
  e.email,
  e.role,
  CASE 
    WHEN a.id IS NOT NULL AND a.encrypted_password IS NOT NULL 
    THEN '✅ Has Password' 
    ELSE '❌ Missing Password' 
  END as password_status
FROM public.employees e
LEFT JOIN auth.users a ON e.id = a.id
ORDER BY e.role, e.employee_code;
```

All rows should show "✅ Has Password".

## Testing Logins

After setup, test with:

- **Employee Code**: `SUP001`
- **Password**: `TestPassword123!`
- **Role**: `Supervisor`

## Troubleshooting

### "User already exists"
- The email is already registered
- Use a different email or delete the existing user first

### "Password too weak"
- Supabase may require stronger passwords
- Use: `TestPassword123!@#`

### "Email not confirmed"
- Make sure "Auto Confirm User" is ON when creating
- Or manually confirm via Dashboard → Users → Action → Confirm

---

**Recommended Password for Testing**: `TestPassword123!`

