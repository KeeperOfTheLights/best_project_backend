# How to Run the Mobile App

## Running from Command Line

The Flutter project is inside the `mobile` folder. You need to navigate to it first:

### PowerShell (Windows)
```powershell
cd mobile
flutter run
```

### Or in one command:
```powershell
cd mobile; flutter run
```

## Running on Different Platforms

### Web
```powershell
cd mobile
flutter run -d chrome
```

### Android Emulator
```powershell
cd mobile
flutter run
```
(Make sure Android emulator is running)

### Windows Desktop
```powershell
cd mobile
flutter run -d windows
```

## Important Notes

1. **Always run from `mobile` directory** - The `pubspec.yaml` file is in `mobile/`
2. **Backend must be running** - The app connects to `http://localhost:8000/api/accounts`
3. **Update base URL if needed** - See `mobile/lib/utils/constants.dart`

## Troubleshooting

### Error: "No pubspec.yaml file found"
- **Solution**: Make sure you're in the `mobile` directory
- **Command**: `cd mobile` then try again

### Error: "CMake Error" or "Unable to generate build files" (Windows)
- **Solution**: Regenerate Windows platform files
- **Command**: 
  ```powershell
  cd mobile
  flutter create --platforms=windows .
  ```
- Then try running again: `flutter run -d windows`

### Error: "Connection error"
- **Solution**: Make sure Django backend is running
- **Command**: In project root, run `python manage.py runserver`

### For Android Emulator
- If backend is on localhost, use `http://10.0.2.2:8000/api/accounts` instead
- Update `baseUrl` in `mobile/lib/utils/constants.dart`

### For Network Testing
- Use your computer's IP address: `http://192.168.1.XXX:8000/api/accounts`
- Update `baseUrl` in `mobile/lib/utils/constants.dart`

### Recommended: Use Chrome for Testing
- Chrome is usually faster and easier for development
- **Command**: `flutter run -d chrome`

