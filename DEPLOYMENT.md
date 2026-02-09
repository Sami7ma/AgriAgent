 🚀 AgriAgent Deployment Guide
## Deploy Backend to Render (FREE)
### Step 1: Push to GitHub
Make sure your code is pushed to GitHub:
```bash
git add .
git commit -m "Add deployment configuration"
git push
```
### Step 2: Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with GitHub (easiest)
### Step 3: Deploy Backend
1. Click **"New +"** → **"Web Service"**
2. Connect your GitHub repo: `Sami7ma/AgriAgent`
3. Configure:
   - **Name**: `agriagent-api`
   - **Root Directory**: `backend`
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT`
   - **Plan**: Free
4. Add Environment Variable:
   - Click **"Environment"** tab
   - Add: `GEMINI_API_KEY` = `your-gemini-api-key-here`
   - Add: `ENVIRONMENT` = `production`
5. Click **"Create Web Service"**
### Step 4: Get Your URL
After deployment, you'll get a URL like:
```
https://agriagent-api.onrender.com
```
### Step 5: Update Flutter App
Edit `frontend/lib/utils/constants.dart`:
```dart
static const String baseUrl = "https://agriagent-api.onrender.com/api/v1";
```
### Step 6: Rebuild App
```bash
cd frontend
flutter build apk --release
```
Your APK will now work anywhere with internet! 🎉
---
## ⚠️ Important Notes
### Free Tier Limitations
- **Spin-down**: App sleeps after 15 min of inactivity
- **Cold start**: First request after sleep takes ~30 seconds
- **750 hours/month**: More than enough for testing
### Upgrade Options
If you need faster response times, upgrade to Render's paid plan ($7/month).
---
## 🔧 Troubleshooting
### "Connection refused"
- Check if the service is running in Render dashboard
- Wait 30 seconds for cold start
### "Internal server error"
- Check Render logs for errors
- Verify GEMINI_API_KEY is set correctly
### API Key Security
Your Gemini API key is stored securely as an environment variable on Render's servers - it's never exposed in the app code.
