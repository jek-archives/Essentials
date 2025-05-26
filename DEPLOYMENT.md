# Deployment Guide for Essentials USTP

This guide provides step-by-step instructions for deploying both the backend and frontend of the Essentials USTP application.

## Backend Deployment (Django)

### 1. Prepare the Environment
```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Database Setup
1. Install PostgreSQL on your server
2. Create a new database:
```sql
CREATE DATABASE essentials_db;
CREATE USER your_db_user WITH PASSWORD 'your_db_password';
GRANT ALL PRIVILEGES ON DATABASE essentials_db TO your_db_user;
```

### 3. Environment Variables
Create a `.env` file in the backend root directory with the following variables:
```env
DJANGO_SECRET_KEY=your-secret-key
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DB_NAME=essentials_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=localhost
DB_PORT=5432
CORS_ALLOWED_ORIGINS=https://your-domain.com
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-specific-password
```

### 4. Database Migrations
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

### 5. Static Files
```bash
python manage.py collectstatic
```

### 6. Deploy to Heroku
1. Install Heroku CLI
2. Login to Heroku:
```bash
heroku login
```

3. Create a new Heroku app:
```bash
heroku create your-app-name
```

4. Set environment variables:
```bash
heroku config:set DJANGO_SECRET_KEY=your-secret-key
heroku config:set DJANGO_DEBUG=False
heroku config:set DJANGO_ALLOWED_HOSTS=your-app-name.herokuapp.com
# Set other environment variables similarly
```

5. Add PostgreSQL addon:
```bash
heroku addons:create heroku-postgresql:hobby-dev
```

6. Deploy:
```bash
git add .
git commit -m "Prepare for deployment"
git push heroku main
```

## Frontend Deployment (Flutter)

### 1. Update API Configuration
1. Update `lib/constants.dart` with your production API URL
2. Build the app with the production API URL:
```bash
flutter build apk --dart-define=API_URL=https://your-backend-domain.com/api
```

### 2. Android Build
1. Generate a keystore:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path to keystore>
```

3. Build release APK:
```bash
flutter build apk --release
```

4. Build App Bundle:
```bash
flutter build appbundle --release
```

### 3. iOS Build
1. Open Xcode:
```bash
cd ios
open Runner.xcworkspace
```

2. Update bundle identifier and version
3. Configure signing certificates
4. Build archive:
```bash
flutter build ios --release
```

### 4. Store Submission

#### Google Play Store
1. Create a developer account
2. Create a new app
3. Upload the app bundle
4. Fill in store listing details
5. Submit for review

#### Apple App Store
1. Create an App Store Connect account
2. Create a new app
3. Upload the build through Xcode
4. Fill in App Store listing details
5. Submit for review

## Post-Deployment Checklist

### Backend
- [ ] Verify all environment variables are set
- [ ] Check database migrations are applied
- [ ] Test all API endpoints
- [ ] Verify static files are served
- [ ] Check email functionality
- [ ] Monitor error logs

### Frontend
- [ ] Test app on multiple devices
- [ ] Verify API connectivity
- [ ] Check all features work in production
- [ ] Monitor crash reports
- [ ] Test offline functionality
- [ ] Verify push notifications

## Monitoring and Maintenance

### Backend
- Set up logging and monitoring
- Regular database backups
- Security updates
- Performance monitoring

### Frontend
- Crash reporting
- Analytics
- User feedback monitoring
- Regular updates and maintenance 