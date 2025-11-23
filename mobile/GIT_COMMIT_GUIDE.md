# Git Commit Guide - Mobile App Backend Connection

## What Was Changed

### ✅ Files Modified (Should be Committed)
All changes are **ONLY in the `mobile/` folder** - your work area:

**Service Files (Backend Connection):**
- `lib/services/api_service.dart` - Fixed authentication to match backend
- `lib/services/catalog_service.dart` - Fixed product endpoints
- `lib/services/chat_service.dart` - Fixed chat endpoints
- `lib/services/complaint_service.dart` - Fixed complaint endpoints
- `lib/services/link_request_service.dart` - Fixed link request endpoints
- `lib/services/order_service.dart` - Fixed order endpoints
- `lib/services/staff_service.dart` - Fixed staff management endpoints

**Provider Files (State Management):**
- `lib/providers/chat_provider.dart` - Updated for new service methods
- `lib/providers/complaint_provider.dart` - Updated for new service methods
- `lib/providers/link_request_provider.dart` - Updated for new service methods
- `lib/providers/order_provider.dart` - Updated for new service methods
- `lib/providers/staff_provider.dart` - Updated for new service methods

**Screen Files (UI):**
- `lib/screens/chat_room_screen.dart` - Fixed chat message sending
- `lib/screens/complaints_management_screen.dart` - Fixed complaint status updates
- `lib/screens/order_details_screen.dart` - Fixed order status updates
- `lib/screens/staff_management_screen.dart` - Fixed staff addition

**Model Files:**
- `lib/models/user.dart` - Added support for backend's `full_name` field
- `lib/models/complaint.dart` - Added `rejected` status constant

**Configuration:**
- `lib/utils/constants.dart` - Updated endpoints and base URL

**Documentation (New Files):**
- `ENDPOINT_FIXES_SUMMARY.md` - Summary of all endpoint changes
- `TESTING_GUIDE.md` - Step-by-step testing instructions
- `HOW_TO_RUN.md` - How to run the app
- `GIT_COMMIT_GUIDE.md` - This file

**Other:**
- `windows/flutter/CMakeLists.txt` - Regenerated (needed for Windows build)

### ❌ Files NOT Modified (Don't Commit)
- **Backend files** (`accounts/`, `best_project/`, `main/`) - Your friends' work, untouched
- **Frontend files** (`frontend/`) - Your friends' work, untouched
- **`__pycache__/` files** - Python cache files, auto-generated (should be in .gitignore)
- **Build files** - Auto-generated, should be ignored

---

## Step-by-Step: How to Commit and Push

### Option 1: Commit All Mobile Changes (Recommended)

```powershell
# 1. Navigate to project root
cd C:\Users\islam\best_project_backend

# 2. Check what will be committed (review the changes)
git status

# 3. Stage only mobile folder changes
git add mobile/

# 4. Verify what's staged (should only show mobile/ files)
git status

# 5. Commit with descriptive message
git commit -m "Connect mobile app to Django backend - Fix all endpoint mismatches

- Updated all service files to match backend API endpoints
- Fixed authentication to handle backend response format (access token)
- Updated providers to pass userRole parameter where needed
- Fixed screens to use new provider method signatures
- Added ComplaintStatus.rejected constant
- Updated User model to handle full_name from backend
- Regenerated Windows platform files for build fix
- Added comprehensive documentation (testing guide, endpoint mapping)"

# 6. Push to GitHub
git push origin main
# OR if you're on a different branch:
# git push origin your-branch-name
```

### Option 2: Create a Feature Branch (Recommended for Team Projects)

```powershell
# 1. Create and switch to new branch
git checkout -b feature/mobile-backend-integration

# 2. Stage mobile changes
git add mobile/

# 3. Commit
git commit -m "Connect mobile app to Django backend - Fix endpoint mismatches"

# 4. Push branch to GitHub
git push origin feature/mobile-backend-integration

# 5. Then create a Pull Request on GitHub for your teammates to review
```

### Option 3: Commit Specific Files Only

If you want to be more selective:

```powershell
# Stage specific files
git add mobile/lib/services/
git add mobile/lib/providers/
git add mobile/lib/screens/
git add mobile/lib/models/
git add mobile/lib/utils/constants.dart
git add mobile/*.md
git add mobile/windows/flutter/CMakeLists.txt

# Commit
git commit -m "Connect mobile app to Django backend"

# Push
git push origin main
```

---

## What NOT to Commit

### ❌ Don't Commit These:

1. **Python Cache Files:**
   ```
   accounts/__pycache__/
   best_project/__pycache__/
   main/__pycache__/
   ```
   These are auto-generated. Make sure `.gitignore` includes `__pycache__/` or `*.pyc`

2. **Flutter Build Files:**
   ```
   mobile/build/
   mobile/.dart_tool/
   mobile/.flutter-plugins
   mobile/.flutter-plugins-dependencies
   ```
   These should be in `mobile/.gitignore`

3. **IDE Files:**
   ```
   .idea/
   .vscode/
   *.iml
   ```

4. **Environment/Config Files with Secrets:**
   ```
   mobile/android/local.properties  # May contain local paths
   ```

---

## Verify Before Pushing

### 1. Check What Will Be Committed

```powershell
git status
```

**Should show:**
- ✅ Files in `mobile/` folder
- ❌ Should NOT show files in `accounts/`, `frontend/`, `best_project/` (unless your friends modified them)

### 2. Review the Changes

```powershell
# See what changed in a specific file
git diff mobile/lib/utils/constants.dart

# See summary of all changes
git diff --stat mobile/
```

### 3. Make Sure .gitignore is Working

```powershell
# Check if __pycache__ is being ignored
git status --ignored | findstr "__pycache__"
```

If `__pycache__` files show up, add to `.gitignore`:
```
__pycache__/
*.pyc
```

---

## Recommended Commit Message

Here's a good commit message format:

```
Connect mobile app to Django backend - Fix endpoint mismatches

Changes:
- Updated all service files to match backend API endpoints
- Fixed authentication to handle backend response format
- Updated providers to work with new service signatures
- Fixed screens to use updated provider methods
- Added missing model constants (ComplaintStatus.rejected)
- Regenerated Windows build files
- Added comprehensive documentation

All changes are isolated to mobile/ folder.
Backend and frontend remain unchanged.
```

---

## After Pushing

### 1. Verify on GitHub
- Go to your GitHub repository
- Check that only `mobile/` files were changed
- Verify commit message is clear

### 2. Notify Your Team
Let your teammates know:
- ✅ Mobile app is now connected to backend
- ✅ All endpoint mismatches are fixed
- ✅ They can test the integration
- 📝 See `mobile/TESTING_GUIDE.md` for testing steps

### 3. Test Together
- Coordinate with backend team to ensure server is running
- Test the connection together
- Fix any remaining issues if found

---

## Troubleshooting

### Problem: "Your branch is behind 'origin/main'"

**Solution:**
```powershell
# Pull latest changes first
git pull origin main

# Resolve any conflicts if they exist
# Then push again
git push origin main
```

### Problem: Accidentally Staged Backend/Frontend Files

**Solution:**
```powershell
# Unstage everything
git reset

# Stage only mobile folder
git add mobile/

# Verify
git status
```

### Problem: Want to Undo a Commit (Before Pushing)

**Solution:**
```powershell
# Undo last commit but keep changes
git reset --soft HEAD~1

# Or undo commit and discard changes (careful!)
git reset --hard HEAD~1
```

---

## Best Practices

1. ✅ **Always review** `git status` before committing
2. ✅ **Write clear commit messages** - your future self will thank you
3. ✅ **Test before pushing** - make sure app compiles and runs
4. ✅ **Use feature branches** for major changes
5. ✅ **Coordinate with team** before pushing breaking changes
6. ✅ **Keep commits focused** - one logical change per commit

---

## Quick Reference

```powershell
# See what changed
git status

# Stage mobile folder
git add mobile/

# Commit
git commit -m "Your message here"

# Push
git push origin main

# Create branch
git checkout -b feature/your-feature-name

# See commit history
git log --oneline -10
```

---

**Ready to push?** Follow Option 1 or Option 2 above! 🚀

