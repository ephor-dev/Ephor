# Bulk User Creation Script

If you want to create all users at once, here's a simple approach:

## Option 1: Use Supabase Dashboard (Easiest)

Create users one by one in the Dashboard (takes ~5 minutes for 10 users).

## Option 2: Create Users via API Script

You can run this in your browser console or as a script.

### Browser Console Script (Quick & Easy)

1. Open Supabase Dashboard → Your Project
2. Go to **Settings → API**
3. Copy your **Service Role Key** (keep it secret!)
4. Open browser console (F12)
5. Paste and run this script:

```javascript
// CONFIGURATION - Update these values
const SUPABASE_URL = 'https://qkvsddnqbsodaukycoaz.supabase.co';
const SERVICE_ROLE_KEY = 'YOUR_SERVICE_ROLE_KEY_HERE'; // From Settings → API

// List of all mock users
const mockUsers = [
  // Supervisors
  { email: 'john.supervisor@ephor.com', password: 'TestPassword123!', code: 'SUP001', name: 'John Mitchell', role: 'Supervisor' },
  { email: 'sarah.chen@ephor.com', password: 'TestPassword123!', code: 'SUP002', name: 'Sarah Chen', role: 'Supervisor' },
  { email: 'michael.rodriguez@ephor.com', password: 'TestPassword123!', code: 'SUP003', name: 'Michael Rodriguez', role: 'Supervisor' },
  { email: 'emily.johnson@ephor.com', password: 'TestPassword123!', code: 'SUP004', name: 'Emily Johnson', role: 'Supervisor' },
  { email: 'david.williams@ephor.com', password: 'TestPassword123!', code: 'SUP005', name: 'David Williams', role: 'Supervisor' },
  // Human Resources
  { email: 'jennifer.martinez@ephor.com', password: 'TestPassword123!', code: 'HR001', name: 'Jennifer Martinez', role: 'Human Resources' },
  { email: 'robert.taylor@ephor.com', password: 'TestPassword123!', code: 'HR002', name: 'Robert Taylor', role: 'Human Resources' },
  { email: 'lisa.anderson@ephor.com', password: 'TestPassword123!', code: 'HR003', name: 'Lisa Anderson', role: 'Human Resources' },
  { email: 'james.wilson@ephor.com', password: 'TestPassword123!', code: 'HR004', name: 'James Wilson', role: 'Human Resources' },
  { email: 'amanda.davis@ephor.com', password: 'TestPassword123!', code: 'HR005', name: 'Amanda Davis', role: 'Human Resources' },
];

async function createUsersAndEmployees() {
  const results = [];
  
  for (const user of mockUsers) {
    try {
      // Create auth user
      const authResponse = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
        method: 'POST',
        headers: {
          'apikey': SERVICE_ROLE_KEY,
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: user.email,
          password: user.password,
          email_confirm: true,
          user_metadata: {
            employee_code: user.code
          }
        })
      });
      
      if (!authResponse.ok) {
        const error = await authResponse.json();
        console.error(`Failed to create auth user for ${user.email}:`, error);
        results.push({ user: user.email, status: 'Failed', error: error.message });
        continue;
      }
      
      const authData = await authResponse.json();
      const userId = authData.id;
      
      // Create employee record
      const empResponse = await fetch(`${SUPABASE_URL}/rest/v1/employees`, {
        method: 'POST',
        headers: {
          'apikey': SERVICE_ROLE_KEY,
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal'
        },
        body: JSON.stringify({
          id: userId,
          employee_code: user.code,
          email: user.email,
          first_name: user.name.split(' ')[0],
          last_name: user.name.split(' ')[1],
          role: user.role
        })
      });
      
      if (empResponse.ok) {
        console.log(`✅ Created: ${user.email} (${user.code})`);
        results.push({ user: user.email, status: 'Success', userId: userId });
      } else {
        const error = await empResponse.text();
        console.error(`Failed to create employee for ${user.email}:`, error);
        results.push({ user: user.email, status: 'Auth OK, Employee Failed', error: error });
      }
      
      // Small delay to avoid rate limits
      await new Promise(resolve => setTimeout(resolve, 200));
      
    } catch (error) {
      console.error(`Error creating ${user.email}:`, error);
      results.push({ user: user.email, status: 'Error', error: error.message });
    }
  }
  
  console.log('\n=== Summary ===');
  results.forEach(r => console.log(`${r.status}: ${r.user}`));
  return results;
}

// Run the script
createUsersAndEmployees().then(results => {
  console.log('\n✅ Done! Created', results.filter(r => r.status === 'Success').length, 'users');
});
```

**⚠️ Security Warning**: Never commit your service_role key to version control!

---

## Simple Manual Approach (Most Reliable)

1. Open Supabase Dashboard → Authentication → Users
2. Click "Add user" → "Create new user"
3. For each user:
   - Email: (from mock data)
   - Password: `TestPassword123!`
   - ✅ Auto Confirm: ON
   - Create
   - Copy UUID
4. Update `mock_data.sql` with UUIDs
5. Run SQL script

This takes about 5-10 minutes for 10 users but is the most reliable method.

