# 🎨 Customize OrangeHRM Favicon and Logo

Guide to replace OrangeHRM branding with Marshall Islands Public School System logo.

---

## 📋 Files to Replace

### **Favicon Locations:**
1. `src/client/public/favicon.ico` - Main application favicon
2. `installer/client/public/favicon.ico` - Installer favicon
3. `web/images/ohrm_branding.png` - Login page branding
4. `web/images/logo.png` - Header logo

---

## 🎯 **Step 1: Prepare Your Logo Files**

You need these formats:

### **1. Favicon (.ico format)**
- Size: 16x16, 32x32, 48x48 (multi-resolution)
- Format: `.ico`
- Name: `favicon.ico`

### **2. PNG Logo (for branding)**
- Size: 200x50 pixels (header)
- Format: `.png`
- Name: `logo.png`

### **3. Branding Image**
- Size: 300x300 pixels (login page)
- Format: `.png`
- Name: `ohrm_branding.png`

---

## 🛠️ **Step 2: Convert Your Logo**

### **Option A: Online Converter (Easiest)**

1. Go to https://favicon.io/
2. Upload your Marshall Islands PSS logo
3. Download the generated favicon.ico
4. Also create PNG versions in required sizes

### **Option B: Using ImageMagick (On Server)**

```bash
# Install ImageMagick
sudo apt install -y imagemagick

# Convert your logo to favicon
convert your-logo.png -resize 32x32 favicon.ico

# Create PNG versions
convert your-logo.png -resize 200x50 logo.png
convert your-logo.png -resize 300x300 ohrm_branding.png
```

### **Option C: Using Online Tools**

- **Favicon**: https://realfavicongenerator.net/
- **Resize**: https://www.iloveimg.com/resize-image

---

## 📂 **Step 3: Upload Logo Files to Server**

### **From Your Computer:**

```bash
# Upload your logo files to the server
scp favicon.ico pssadmin@192.168.84.126:/tmp/
scp logo.png pssadmin@192.168.84.126:/tmp/
scp ohrm_branding.png pssadmin@192.168.84.126:/tmp/
```

---

## 🔄 **Step 4: Replace Favicon in Docker Container**

On your OrangeHRM server:

```bash
cd /opt/orangehrm

# Copy favicon to main application
docker cp /tmp/favicon.ico orangehrm_app:/var/www/html/src/client/public/favicon.ico

# Copy favicon to installer
docker cp /tmp/favicon.ico orangehrm_app:/var/www/html/installer/client/public/favicon.ico

# Copy logo for header
docker cp /tmp/logo.png orangehrm_app:/var/www/html/web/images/logo.png

# Copy branding image for login page
docker cp /tmp/ohrm_branding.png orangehrm_app:/var/www/html/web/images/ohrm_branding.png

# Copy to default photo location
docker cp /tmp/logo.png orangehrm_app:/var/www/html/web/images/orangehrm-logo.png
```

---

## 🔄 **Step 5: Clear Browser Cache**

```bash
# Restart OrangeHRM container to ensure changes take effect
docker compose -f docker-compose.no-nginx.yml restart orangehrm

# Wait a few seconds
sleep 5

# Check if files were updated
docker compose -f docker-compose.no-nginx.yml exec orangehrm ls -lh /var/www/html/src/client/public/favicon.ico
docker compose -f docker-compose.no-nginx.yml exec orangehrm ls -lh /var/www/html/web/images/logo.png
```

---

## 🎨 **Step 6: Customize via OrangeHRM Admin Panel (After Installation)**

After completing the installation, you can customize branding through the admin panel:

1. **Login as Admin**
2. Go to **Admin** → **Configuration** → **Organization**
3. Upload your logo
4. Go to **Admin** → **Corporate Branding**
5. Upload:
   - Client Logo (header)
   - Client Banner (login page)
   - Login Banner (background)

---

## 📋 **Alternative: Mount Local Files (Persistent)**

To make changes permanent across container restarts:

### **Create a custom directory:**

```bash
# On OrangeHRM server
mkdir -p /opt/orangehrm/custom/images

# Copy your logo files there
cp /tmp/favicon.ico /opt/orangehrm/custom/images/
cp /tmp/logo.png /opt/orangehrm/custom/images/
cp /tmp/ohrm_branding.png /opt/orangehrm/custom/images/
```

### **Edit docker-compose.no-nginx.yml:**

```bash
nano docker-compose.no-nginx.yml
```

Add these volume mounts under the `orangehrm` service:

```yaml
    volumes:
      - orangehrm_data:/var/www/html
      - ./custom/images/favicon.ico:/var/www/html/src/client/public/favicon.ico:ro
      - ./custom/images/favicon.ico:/var/www/html/installer/client/public/favicon.ico:ro
      - ./custom/images/logo.png:/var/www/html/web/images/logo.png:ro
      - ./custom/images/ohrm_branding.png:/var/www/html/web/images/ohrm_branding.png:ro
```

Then restart:

```bash
docker compose -f docker-compose.no-nginx.yml down
docker compose -f docker-compose.no-nginx.yml up -d
```

---

## ✅ **Verify Changes**

1. **Clear browser cache**: Ctrl+Shift+Delete
2. **Access application**: https://hrm.pss.edu.mh
3. **Check favicon**: Should show your logo in browser tab
4. **Check login page**: Should show your branding

---

## 🎨 **Additional Branding Locations**

After installation, you can also customize:

### **Database Configuration** (via Admin Panel):
- Login banner
- Client logo  
- Client banner
- Email headers
- Report headers

### **Theme Colors** (via Corporate Branding):
- Primary color
- Secondary color
- Login page background

---

## 📝 **Quick Reference**

```bash
# Upload logo from your computer
scp favicon.ico pssadmin@192.168.84.126:/tmp/

# Copy to container
docker cp /tmp/favicon.ico orangehrm_app:/var/www/html/src/client/public/favicon.ico

# Restart
docker compose -f docker-compose.no-nginx.yml restart orangehrm

# Clear browser cache and refresh
```

---

## 🎯 **Recommended Approach**

1. **Complete OrangeHRM installation first**
2. **Use Admin → Corporate Branding** to upload logos (easiest)
3. **For favicon**: Use the Docker cp method above
4. **For persistent changes**: Use volume mounts in docker-compose.yml

---

**First, complete the installation wizard, then we can customize the branding!** 🚀

Your Marshall Islands Public School System logo will look great in OrangeHRM! 🎉
