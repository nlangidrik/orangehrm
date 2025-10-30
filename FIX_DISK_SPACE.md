# 🚨 Fix: No Space Left on Device

## Quick Diagnosis

Run these commands to check disk usage:

```bash
# Check disk space
df -h

# Check which directories are using the most space
du -sh /opt/* | sort -rh | head -10
du -sh /var/* | sort -rh | head -10
du -sh /home/* | sort -rh | head -10
```

---

## 🔧 Quick Fixes (Choose Based on What's Full)

### **Option 1: Clean Docker (Most Common)**

Docker images and containers can take up a lot of space:

```bash
# Check Docker disk usage
docker system df

# Remove unused Docker data (safe)
docker system prune -a --volumes

# When prompted, type 'y' and press Enter

# Check space again
df -h
```

**This usually frees up several GB!**

---

### **Option 2: Clean APT Cache**

```bash
# Clean package cache
sudo apt clean
sudo apt autoclean
sudo apt autoremove -y

# Check space
df -h
```

---

### **Option 3: Clean Log Files**

```bash
# Check log sizes
sudo du -sh /var/log/*

# Truncate large log files (keeps files but empties them)
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/kern.log
sudo truncate -s 0 /var/log/auth.log

# Or delete old logs
sudo find /var/log -type f -name "*.gz" -delete
sudo find /var/log -type f -name "*.log.*" -delete
sudo journalctl --vacuum-time=7d

# Check space
df -h
```

---

### **Option 4: Clean Temporary Files**

```bash
# Clear temp files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Check space
df -h
```

---

### **Option 5: Find Large Files**

```bash
# Find files larger than 100MB
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh | head -20

# Once you identify large files, delete if not needed
sudo rm /path/to/large/file
```

---

## ⚡ **Recommended Quick Fix (All-in-One)**

Run this complete cleanup:

```bash
# Clean Docker
docker system prune -a --volumes -f

# Clean APT
sudo apt clean
sudo apt autoclean
sudo apt autoremove -y

# Clean logs
sudo journalctl --vacuum-time=7d
sudo find /var/log -type f -name "*.gz" -delete

# Clean temp
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Check space
df -h
```

---

## 📊 **After Cleanup, Check Space**

```bash
# Should now show more available space
df -h

# Look for these lines:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        20G   15G   4G  80% /         (Should be under 90%)
```

---

## ✅ **Then Retry Your Command**

```bash
cd /opt/orangehrm
cp env.no-nginx.example .env
```

Should work now!

---

## 🔍 **If Still Out of Space**

### Check what's using space:

```bash
# Check by directory (sorted, largest first)
sudo du -h --max-depth=1 / 2>/dev/null | sort -rh | head -20
```

### Common culprits:

1. **Docker:** `/var/lib/docker/`
   ```bash
   sudo du -sh /var/lib/docker/
   docker system prune -a --volumes -f
   ```

2. **Logs:** `/var/log/`
   ```bash
   sudo du -sh /var/log/
   sudo journalctl --vacuum-size=100M
   ```

3. **Old kernels:** 
   ```bash
   dpkg -l | grep linux-image
   sudo apt autoremove -y
   ```

4. **Git repositories:**
   ```bash
   # Clean up git cache in your repo
   cd /opt/orangehrm
   git gc --aggressive --prune=now
   ```

---

## 💡 **Prevent Future Issues**

### 1. Set up log rotation

```bash
sudo nano /etc/logrotate.conf
```

Ensure these lines exist:
```
rotate 7
daily
compress
```

### 2. Regular Docker cleanup

Add to crontab:
```bash
crontab -e
```

Add:
```
0 3 * * 0 docker system prune -af --volumes
```

### 3. Monitor disk space

```bash
# Add to your bashrc for a warning
echo 'df -h | grep -E "^/dev/" | awk '"'"'{if($5+0 > 80) print "WARNING: "$0}'"'"'' >> ~/.bashrc
```

---

## 🆘 **Emergency: Expand Disk Space**

If you genuinely need more space (not just cleanup):

### Check if you can resize:
```bash
lsblk
```

### For cloud servers (AWS, DigitalOcean, etc.):
1. Resize volume in your cloud console
2. Resize partition:
   ```bash
   sudo growpart /dev/sda 1
   sudo resize2fs /dev/sda1
   ```

---

## 📝 **Quick Reference**

```bash
# Check space
df -h

# Quick cleanup
docker system prune -af --volumes && sudo apt clean && sudo apt autoremove -y

# Check space again
df -h

# Retry your command
cd /opt/orangehrm && cp env.no-nginx.example .env
```

---

**After cleanup, you should have enough space to continue with the installation!** 🚀
