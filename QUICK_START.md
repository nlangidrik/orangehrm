# OrangeHRM Quick Start Guide

## ✅ Your Application is Running!

Your OrangeHRM application is now running on Docker.

## 🌐 Access URLs

- **Application URL**: http://localhost:8080
- **Direct IP Access**: http://127.0.0.1:8080

## 🔐 Initial Setup

When you first access the application, you'll see the OrangeHRM installer.

### Installation Steps:

1. **Welcome Screen**: Click "Next"

2. **License Agreement**: Accept the license and click "Next"

3. **Database Configuration**:
   - Host Name: `mysql`
   - Port: `3306`
   - Database Name: `orangehrm_mysql`
   - Database User: `orangehrm`
   - Database Password: `orangehrm123`
   - Click "Next"

4. **System Check**: Verify all requirements are met, click "Next"

5. **Admin User Configuration**:
   - Employee Name: Your name
   - Username: `Admin` (or your preferred username)
   - Password: Choose a strong password
   - Email: Your email address
   - Click "Next"

6. **Confirmation**: Review and click "Install"

7. **Installation Complete**: Click "Next" to login

## 📋 Docker Commands

### View Running Containers
```bash
docker-compose -f docker-compose.simple.yml ps
```

### View Logs
```bash
# All logs
docker-compose -f docker-compose.simple.yml logs -f

# Only OrangeHRM logs
docker-compose -f docker-compose.simple.yml logs -f orangehrm

# Only MySQL logs
docker-compose -f docker-compose.simple.yml logs -f mysql
```

### Stop the Application
```bash
docker-compose -f docker-compose.simple.yml down
```

### Start the Application
```bash
docker-compose -f docker-compose.simple.yml up -d
```

### Restart the Application
```bash
docker-compose -f docker-compose.simple.yml restart
```

### Stop and Remove All Data (⚠️ Warning: This will delete all data!)
```bash
docker-compose -f docker-compose.simple.yml down -v
```

## 🗄️ Database Information

- **Host**: localhost
- **Port**: 3306
- **Database**: orangehrm_mysql
- **Username**: orangehrm
- **Password**: orangehrm123
- **Root Password**: rootpassword123

### Connect to MySQL
```bash
docker exec -it orangehrm_mysql mysql -u orangehrm -porangehrm123 orangehrm_mysql
```

## 🔧 Troubleshooting

### Application Not Loading

1. Check if containers are running:
   ```bash
   docker-compose -f docker-compose.simple.yml ps
   ```

2. View error logs:
   ```bash
   docker-compose -f docker-compose.simple.yml logs orangehrm
   ```

3. Restart the application:
   ```bash
   docker-compose -f docker-compose.simple.yml restart
   ```

### Database Connection Issues

1. Check MySQL is healthy:
   ```bash
   docker-compose -f docker-compose.simple.yml ps mysql
   ```

2. Wait for MySQL to be fully ready (may take 30-60 seconds on first start)

3. Check MySQL logs:
   ```bash
   docker-compose -f docker-compose.simple.yml logs mysql
   ```

### Port Already in Use

If port 8080 or 3306 is already in use, edit `docker-compose.simple.yml`:
- Change `8080:80` to `9090:80` (or another available port)
- Change `3306:3306` to `3307:3306` (or another available port)

Then restart:
```bash
docker-compose -f docker-compose.simple.yml down
docker-compose -f docker-compose.simple.yml up -d
```

## 📁 Data Persistence

Your data is stored in Docker volumes:
- `orangehrm-1_mysql_data` - Database data
- `orangehrm-1_orangehrm_data` - Application files

Even if you stop the containers, your data remains safe.

## 🚀 Next Steps

1. Complete the web installer
2. Login with your admin credentials
3. Configure your organization settings
4. Add employees and users
5. Explore the features!

## 📚 Additional Resources

- OrangeHRM Documentation: https://starterhelp.orangehrm.com
- OrangeHRM Demo: https://opensource-demo.orangehrmlive.com

## 💡 Tips

- Change the default admin password after first login
- Regularly backup your database
- Keep Docker images updated
- Monitor container logs for errors

## ⚠️ Security Note

The current setup uses default passwords. For production use:
1. Change all default passwords
2. Use strong, unique passwords
3. Enable SSL/HTTPS
4. Restrict database access
5. Use environment variables for sensitive data

Enjoy using OrangeHRM! 🎉
