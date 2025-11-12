# Fix "Email is Not Confirmed" Error

This error occurs when auth users haven't confirmed their email addresses. Here are quick fixes:

## Solution 1: Manually Confirm Users in Dashboard (Easiest)

### For Existing Users:

1. **Go to Supabase Dashboard**
   - Navigate to **Authentication** → **Users**
   
2. **Find the user** (search by email)

3. **Confirm the user:**
   - Click on the user to open details
   - Look for **"Email Confirmed"** status
   - If it shows "Not confirmed", click the **three dots (⋮)** menu
   - Select **"Confirm email"** or **"Send confirmation email"**
   - Or manually set `email_confirmed_at` to current timestamp

4. **Repeat for all users**

### Bulk Confirm via SQL (Quick Method):

If you have many users, you can confirm them all at once via SQL:

```sql
-- Confirm all users' emails (sets email_confirmed_at to NOW)
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;
```

**⚠️ Note**: This requires service_role permissions. Run in SQL Editor with elevated privileges.

---

## Solution 2: Disable Email Confirmation Requirement

### For Testing/Development:

1. **Go to Supabase Dashboard**
   - Navigate to **Authentication** → **Settings**

2. **Disable email confirmation:**
   - Find **"Enable email confirmations"**
   - Turn it **OFF** (for development/testing only)
   - Click **Save**

3. **Test login again**

**⚠️ Warning**: Only do this for development/testing! Production apps should require email confirmation.

---

## Solution 3: Create New Users with Auto-Confirm

If you need to recreate users:

1. **Delete old unconfirmed users** (Dashboard → Authentication → Users)
2. **Create new users** with:
   - ✅ **Auto Confirm User**: ON
   - This ensures they're confirmed immediately

---

## Solution 4: Confirm Users via API

You can use the Supabase Admin API to confirm users programmatically:

### Using Browser Console:

```javascript
// Replace with your values
const SUPABASE_URL = 'https://qkvsddnqbsodaukycoaz.supabase.co';
const SERVICE_ROLE_KEY = 'YOUR_SERVICE_ROLE_KEY'; // From Settings → API

// Confirm all users
async function confirmAllUsers() {
  // First, get all users
  const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
    headers: {
      'apikey': SERVICE_ROLE_KEY,
      'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
    }
  });
  
  const users = await response.json();
  
  // Confirm each user
  for (const user of users.users) {
    if (!user.email_confirmed_at) {
      await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${user.id}`, {
        method: 'PUT',
        headers: {
          'apikey': SERVICE_ROLE_KEY,
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email_confirm: true
        })
      });
      console.log(`✅ Confirmed: ${user.email}`);
    }
  }
}

confirmAllUsers();
```

---

## Quick Fix Checklist

- [ ] Check if users are confirmed (Dashboard → Users → Check "Email Confirmed" status)
- [ ] If not confirmed: Run SQL query to confirm all OR manually confirm in Dashboard
- [ ] Try login again
- [ ] If still failing: Check Supabase Auth settings for email confirmation requirement

## Verify Users Are Confirmed

Run this SQL query to check:

```sql
SELECT 
  email,
  email_confirmed_at,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN '✅ Confirmed'
    ELSE '❌ Not Confirmed'
  END as status
FROM auth.users
ORDER BY email;
```

All users should show "✅ Confirmed" for login to work.

---

## For Future Users

When creating new users, always:
- ✅ Enable **"Auto Confirm User"** in Dashboard
- ✅ Or set `email_confirm: true` in API calls

This prevents the "email not confirmed" error.

