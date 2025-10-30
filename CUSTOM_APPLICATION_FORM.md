# Custom Job Application Form - Marshall Islands PSS

## ✅ **Changes Made to Application Form**

I've added all the personal details fields from your PSS application form template:

### **New Fields Added:**

#### **Personal Information:**
1. Social Security No.
2. Date of Birth (required)
3. Place of Birth
4. Sex (Male/Female) - required
5. Marital Status (Married, Widowed, Separated, Single, Divorced) - required

#### **Home Address:**
6. Home Address
7. City
8. Country/State  
9. Zip Code
10. Phone No.
11. Cell No.

#### **Correspondence Address:**
12. Correspondence Address
13. City
14. Country/State
15. Zip Code

#### **Citizenship:**
16. Citizen of Marshalls (Yes/No) - required
17. If NO, Nationality

#### **Family Information:**
18. Children's Ages

#### **Next of Kin:**
19. Next of Kin Name
20. Relationship
21. Address
22. City
23. Country/State
24. Zip Code

---

## 📁 **Files Modified:**

- `src/client/src/orangehrmRecruitmentPlugin/pages/ApplyJobVacancy.vue`
  - Added 25 new fields to the applicant model
  - Added validation rules for all fields
  - Added form fields in the template

---

## 🔧 **To Apply Changes (Requires Frontend Rebuild):**

### **Option 1: Rebuild Frontend (Production)**

On your production server:

```bash
cd /opt/orangehrm

# Pull latest changes
git pull origin docker-setup

# Install Node.js and Yarn
sudo apt install -y nodejs npm
sudo npm install -g yarn

# Build frontend
cd src/client
yarn install
yarn build

# Restart Docker
cd /opt/orangehrm
docker compose -f docker-compose.no-nginx.yml restart orangehrm
```

### **Option 2: Wait for Pre-built Version**

The changes are committed to your GitHub repo. When OrangeHRM releases an updated version or you rebuild the image, the changes will be included.

### **Option 3: Use OrangeHRM Starter Advanced**

Consider upgrading to OrangeHRM Advanced/Pro which allows custom form fields through the admin panel without code changes.

---

## 🎯 **Alternative: Use Custom Forms Plugin**

For now, you can:

1. **Collect additional info in the "Notes" field**
2. **Ask applicants to include details in their resume**
3. **Add custom questions in the job vacancy description**
4. **Use OrangeHRM's API to create custom intake forms**

---

## 📋 **Current Form (Without Rebuild):**

The application form currently shows:
- Full Name
- Email
- Contact Number
- Resume Upload
- Keywords
- Notes ← Applicants can add extra info here
- Consent checkbox

---

## 🔄 **After Frontend Rebuild:**

The form will include all PSS personal details fields matching your template.

---

## 💡 **Recommendation:**

Since rebuilding the frontend is complex and time-consuming, I recommend:

1. **For now**: Use the Notes field for additional information
2. **Provide instructions** in the job vacancy description
3. **Later**: Schedule a proper frontend rebuild when convenient

Or we can explore creating a separate custom intake form using PHP only (no JavaScript rebuild needed).

---

## 🛠️ **Alternative: Create Custom PHP Form**

I can create a standalone custom PHP form that:
- Collects all PSS fields
- Stores data separately
- Links to OrangeHRM applicants
- Doesn't require frontend rebuild

Would you like me to create this instead?

---

**Let me know if you want to:**
A) Rebuild the frontend now (30-60 minutes)
B) Create a custom PHP form instead (15 minutes)
C) Use the Notes field for now and rebuild later

🚀
