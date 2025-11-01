# Custom Job Application Form - Marshall Islands PSS

## ✅ **Changes Made to Application Form**

I've added all sections from your PSS application form template:

### **Section 1: Personal Details**
1. Social Security No.
2. Date of Birth (required)
3. Place of Birth
4. Sex (Male/Female) - required
5. Marital Status (Married, Widowed, Separated, Single, Divorced) - required
6. Home Address (Address, City, State, Zip, Phone, Cell)
7. Correspondence Address (Address, City, State, Zip)
8. Citizen of Marshalls (Yes/No) - required
9. If NO, Nationality
10. Children's Ages
11. Next of Kin (Name, Relationship, Address, City, State, Zip)

### **Section 2: References**
- 3 References (First Name, Last Name, Phone, Email)

### **Section 3: Training/Workshops**
- 4 Training entries (Course Title, From, To, Location)

### **Section 4: Formal Education**
- High Schools (3 entries): School Name, From, To, Highest Grade/Diploma
- Colleges/Universities (3 entries): College/University, From, To, Major, Degree/Credit Hours

### **Section 5: Hobbies, Sports & Special Skills** ✨
- 4 rows for Hobbies, Sports or Special Interests
- 4 rows for Special Skills

### **Section 6: Details of Employment** ✨
- 7 Employment entries with:
  - Employer
  - From
  - To
  - Job Title
  - Salary
  - Reason for Leaving

### **Section 7: Supporting Documents** ✨
- Resume/CV Upload (Required)
- Reference Letter 1 (Required)
- Reference Letter 2 (Required)
- Valid Driver License or Passport (Required)
- Degree(s) Upload (Required) - **Supports multiple files** 🎓
- Health Clearance (Required)
- Criminal Clearance (Required)
- Certificate(s) Upload (Optional) - **Supports multiple files** 📜
- RMI Social Security Card (Optional)
- Accepts PDF, DOC, DOCX formats
- Maximum file size configurable per file

---

## 📁 **Files Modified:**

- `src/client/src/orangehrmRecruitmentPlugin/pages/ApplyJobVacancy.vue`
  - Added all 7 sections from PSS application form
  - Added 100+ fields to the applicant model
  - Added validation rules for all fields
  - Added form fields in the template
  - Data is compiled and saved in the applicant's comments field

---

## 🔧 **To Apply Changes (Requires Frontend Rebuild):**

### **🚀 Quick Rebuild (Recommended)**

Rebuild and restart the Docker container with the updated code:

```powershell
cd C:\Users\NewtonLangidrik\Documents\Cursor\HRM\orangehrm-3

# Stop the current containers
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx down

# Rebuild the OrangeHRM image with updated code
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx build --no-cache orangehrm

# Start the containers again
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx up -d
```

The rebuild process will:
1. Install all dependencies
2. Build the main app frontend (including your custom application form)
3. Build the installer frontend
4. Create a new Docker image with all changes

**Expected time:** 5-10 minutes depending on your system

---

### **✅ Verify Changes**

After rebuilding:
1. Open http://localhost:8080 in your browser
2. Navigate to Recruitment → Vacancies
3. Create a test vacancy or open an existing one
4. Click "Apply" and you should see all 7 sections:
   - Section 1: Personal Details
   - Section 2: References (3 entries)
   - Section 3: Training/Workshops (4 entries)
   - Section 4: Formal Education (High Schools & Colleges)
   - Section 5: Hobbies, Sports & Special Skills
   - Section 6: Details of Employment (7 rows)
   - Section 7: Supporting Documents (7 Required + 2 Optional, with multi-file support)

---

### **📝 Alternative: Manual Frontend Build**

If you prefer to build the frontend separately:

```powershell
# Enter the running container
docker exec -it orangehrm_app bash

# Inside the container:
cd /var/www/html/src/client
yarn install
yarn build

# Exit container
exit

# Restart the app
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx restart orangehrm
```

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
