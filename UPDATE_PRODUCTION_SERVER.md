# Update Production Server - PSS Application Form

## 🚀 **Quick Update Guide**

Follow these steps to deploy the complete PSS application form to your production server.

---

## 📋 **Prerequisites:**

- SSH access to your production server
- Git installed on production server
- Docker and Docker Compose installed
- Current OrangeHRM installation running

---

## 🔧 **Step-by-Step Update Process:**

### **IMPORTANT: Merge to Main First (Do this ONCE on your local machine):**

Before updating production, merge the feature branch to main on your local machine:

```powershell
# On your local Windows machine
cd C:\Users\NewtonLangidrik\Documents\Cursor\HRM\orangehrm-3

# Switch to main branch
git checkout main

# Pull latest main
git pull origin main

# Merge the feature branch
git merge feature/complete-pss-application-form

# Push to GitHub
git push origin main
```

---

### **Step 1: SSH into Your Production Server**

```bash
ssh your-username@your-production-server-ip
```

---

### **Step 2: Navigate to OrangeHRM Directory**

```bash
cd /opt/orangehrm
# Or wherever your OrangeHRM is installed
```

---

### **Step 3: Ensure You're on Main Branch**

```bash
# Switch to main branch
git checkout main

# Verify you're on main
git branch
```

---

### **Step 4: Pull Latest Changes from Main Branch**

```bash
# Pull the latest updates from main branch
git pull origin main
```

---

### **Step 5: Stop Current Containers**

```bash
# Stop the running containers
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx down

# OR if you want to keep the database data:
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx stop
```

---

### **Step 6: Rebuild the OrangeHRM Image**

```bash
# Rebuild the container with updated code
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx build --no-cache orangehrm
```

This will:
- Install all dependencies
- Build the updated frontend with your custom application form
- Create a fresh Docker image

**Expected time:** 5-10 minutes

---

### **Step 7: Start the Containers**

```bash
# Start all containers
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx up -d

# Verify all containers are running
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx ps
```

---

### **Step 8: Verify the Update**

```bash
# Check application logs
docker logs orangehrm_app --tail 50

# Verify the app is responding
curl -I http://localhost:8080
```

---

### **Step 9: Test the Application**

1. Open your application URL (e.g., http://hrm.pss.edu.mh)
2. Login with admin credentials
3. Navigate to **Recruitment → Vacancies**
4. Click on a vacancy and click "Apply"
5. Verify all 7 sections are visible:
   - Section 1: Personal Details
   - Section 2: References
   - Section 3: Training/Workshops
   - Section 4: Formal Education
   - Section 5: Hobbies, Sports & Special Skills
   - Section 6: Details of Employment
   - Section 7: Supporting Documents (9 upload fields)

---

## 🔄 **Quick Update Commands (All-in-One)**

**FIRST:** Merge to main on your local machine (do this once):

```powershell
# On your Windows machine
cd C:\Users\NewtonLangidrik\Documents\Cursor\HRM\orangehrm-3
git checkout main
git pull origin main
git merge feature/complete-pss-application-form
git push origin main
```

**THEN:** Copy and paste this entire block on your production server:

```bash
cd /opt/orangehrm

# Switch to main and pull latest
git checkout main
git pull origin main

# Stop containers
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx down

# Rebuild with new code
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx build --no-cache orangehrm

# Start containers
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx up -d

# Check status
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx ps

echo "✅ Update complete! Check http://localhost:8080"
```

---

## ⚠️ **Important Notes:**

### **Database Data:**
- Using `down` without `-v` preserves your database data
- All existing employee, vacancy, and applicant data will remain intact
- Only the application code is updated

### **Downtime:**
- Expected downtime: 5-10 minutes during rebuild
- Users will not be able to access the system during this time
- Schedule during low-traffic hours if possible

### **Rollback Plan:**
If something goes wrong, you can rollback:

```bash
# Switch back to main branch
git checkout main

# Rebuild
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx build --no-cache orangehrm

# Restart
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx up -d
```

---

## 🔍 **Troubleshooting:**

### **If containers won't start:**

```bash
# Check logs
docker logs orangehrm_app
docker logs orangehrm_mysql

# Restart individual service
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx restart orangehrm
```

### **If MySQL is unhealthy:**

```bash
# Wait for MySQL to initialize
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx up -d mysql
sleep 30
docker-compose -f docker-compose.no-nginx.yml --env-file env.no-nginx up -d orangehrm
```

### **Clear browser cache:**
After update, users should clear their browser cache or do a hard refresh (Ctrl+F5) to see the new form.

---

## 📊 **What's New in This Update:**

### **New Sections:**
- ✅ Section 5: Hobbies & Skills (8 fields)
- ✅ Section 6: Employment History (42 fields - 7 entries × 6 fields each)
- ✅ Section 7: Supporting Documents (9 upload fields)

### **Document Upload Features:**
- ✅ 7 Required documents (Resume, 2 Reference Letters, ID, Degrees, Health & Criminal Clearance)
- ✅ 2 Optional documents (Certificates, RMI SSN Card)
- ✅ Multi-file upload support for Degree(s) and Certificate(s)
- ✅ File validation for size and type

### **Total Addition:**
- **50+ new form fields**
- **9 document upload fields**
- **Full validation on all fields**

---

## 🎯 **Post-Update Verification Checklist:**

- [ ] All containers running (mysql, redis, orangehrm_app)
- [ ] Application accessible at main URL
- [ ] Login successful
- [ ] Recruitment module accessible
- [ ] Job application form shows all 7 sections
- [ ] All document upload fields visible
- [ ] Test submission works
- [ ] Browser cache cleared for users

---

## 📞 **Need Help?**

If you encounter any issues during the update:
1. Check the container logs: `docker logs orangehrm_app`
2. Verify all containers are running: `docker ps`
3. Check disk space: `df -h`
4. Rollback to previous version if needed (see Rollback Plan above)

---

## ✅ **Success Indicators:**

You'll know the update was successful when:
- ✅ All containers show status "Up" with no restarts
- ✅ Application loads without errors
- ✅ Job application form shows all 7 sections
- ✅ Document upload fields are functional
- ✅ Test applicant submission works

---

**Good luck with your deployment! 🚀**

