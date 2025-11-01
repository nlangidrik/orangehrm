# Rebuild OrangeHRM with Custom Application Form Fields

## 🎯 What This Does

Your **Dockerfile has been updated** to:
- ✅ Use your **local source code** (instead of downloading from SourceForge)
- ✅ Include all your **custom application form fields**
- ✅ Automatically **build the Vue.js frontend** during Docker build
- ✅ Make changes visible immediately when you start the container

**Every fresh build will now include your custom code!**

## 📋 Prerequisites

- Docker Desktop installed and running
- Your custom changes committed to Git
- `.env` file configured (copy from `env.no-nginx.example`)

## 🚀 Rebuild Instructions

### Step 1: Stop and Remove Old Containers

```powershell
docker-compose -f docker-compose.no-nginx.yml down
```

### Step 2: Remove Old Images (Optional but Recommended)

```powershell
docker rmi orangehrm-2-orangehrm
```

### Step 3: Build Fresh with Custom Dockerfile

```powershell
docker-compose -f docker-compose.no-nginx.yml build --no-cache
```

**Note:** This will take 10-20 minutes because it:
- Installs Node.js and Yarn
- Installs all frontend dependencies
- Compiles all Vue.js components (including your custom form)
- Sets up PHP and Apache

### Step 4: Start Containers

```powershell
docker-compose -f docker-compose.no-nginx.yml up -d
```

### Step 5: Verify

Open http://localhost:8080 and navigate to:
- Recruitment → Vacancies → Apply for a job

You should now see ALL your custom fields:
- Personal Details (SSN, DOB, Gender, etc.)
- Home & Correspondence Address
- Citizenship fields
- Next of Kin
- 3 References
- 4 Training/Workshop entries
- 3 High Schools
- 3 College/University entries

## 🔄 Future Updates

When you make changes to Vue files:

### Option A: Rebuild Everything (Slower but Clean)
```powershell
docker-compose -f docker-compose.no-nginx.yml down
docker-compose -f docker-compose.no-nginx.yml build --no-cache
docker-compose -f docker-compose.no-nginx.yml up -d
```

### Option B: Rebuild Frontend Only (Faster)
```powershell
docker exec -it orangehrm_app bash -c "cd /var/www/html/src/client && yarn build"
docker-compose -f docker-compose.no-nginx.yml restart orangehrm
```

## 📁 Files Modified

- **Dockerfile** - Updated to build from local source code with Vue.js frontend compilation
- **.dockerignore** - Excludes unnecessary files for faster builds
- **docker-compose.no-nginx.yml** - Uses the updated Dockerfile

## ⚡ Quick Start (One Command)

```powershell
# Stop, rebuild, and restart everything
docker-compose -f docker-compose.no-nginx.yml down && docker-compose -f docker-compose.no-nginx.yml build --no-cache && docker-compose -f docker-compose.no-nginx.yml up -d
```

## 🐛 Troubleshooting

### Build fails during "yarn install"
- Check your internet connection
- Try again (npm registry can be flaky)

### Build fails during "yarn build"
- Check syntax errors in `.vue` files
- Look at build logs for specific errors

### Changes not showing
- Clear browser cache (Ctrl+Shift+R)
- Check that container was rebuilt (not just restarted)
- Verify build completed successfully without errors

### Container won't start
- Check logs: `docker logs orangehrm_app`
- Verify .env file exists and is valid
- Check if ports 8080 is available

## 💡 Tips

1. **First build is slow** - Node.js install + frontend build takes time
2. **Subsequent builds are faster** - Docker caches layers
3. **Keep node_modules out of Git** - It's huge and rebuilt each time
4. **Test locally before pushing** - Build and verify changes work

## 🎉 Success!

Once built, your custom application form will be live and ready to collect:
- Complete personal information
- Marshall Islands citizenship details
- Educational background
- Professional references
- Training history

All data is saved in the OrangeHRM database and visible in the admin panel!

