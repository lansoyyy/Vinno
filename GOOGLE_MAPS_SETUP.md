# Google Maps Setup for Android

## Steps to Configure Google Maps API

### 1. Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable **Maps SDK for Android** API
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Copy your API key

### 2. Configure Android

#### Update `android/app/src/main/AndroidManifest.xml`

Add the following inside the `<application>` tag:

```xml
<application>
    <!-- Add this meta-data tag -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
    
    <!-- Rest of your application code -->
</application>
```

Replace `YOUR_API_KEY_HERE` with your actual Google Maps API key.

#### Update `android/app/build.gradle`

Make sure your `minSdkVersion` is at least 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be at least 21
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

### 3. Add Permissions

The permissions are already handled by the `google_maps_flutter` package, but ensure these are in your `AndroidManifest.xml`:

```xml
<manifest>
    <!-- Internet permission -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application>
        ...
    </application>
</manifest>
```

### 4. Install Dependencies

Run the following command to install the packages:

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Troubleshooting

### Map not showing
- Verify your API key is correct
- Make sure Maps SDK for Android is enabled in Google Cloud Console
- Check that billing is enabled for your Google Cloud project

### Location not working
- Grant location permissions when prompted
- Check that GPS is enabled on your device
- For emulator, set a location in the emulator settings

### Build errors
- Run `flutter clean` then `flutter pub get`
- Make sure `minSdkVersion` is at least 21
- Rebuild the app

## Package Documentation

- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
- [geolocator](https://pub.dev/packages/geolocator)
- [permission_handler](https://pub.dev/packages/permission_handler)
