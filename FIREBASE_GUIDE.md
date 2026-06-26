# Firebase Integration Guide for TickIt

This guide provides a comprehensive step-by-step walk-through to integrate Firebase Authentication (Email/Password & Google Sign-In) and Cloud Firestore into your TickIt Flutter application.

---

## Prerequisites

Before starting, ensure you have the following installed on your development machine:
1. **Node.js** (required for Firebase CLI) — [Download Node.js](https://nodejs.org/)
2. **Flutter SDK**
3. **Dart SDK** (comes bundled with Flutter)

---

## Step 1: Create a Firebase Project in the Console

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or **Create a project**).
3. Enter the project name: `TickIt`.
4. Choose whether to enable Google Analytics (optional, recommended) and click **Continue**.
5. Once your project is ready, click **Continue** to go to the project overview page.

---

## Step 2: Enable Firebase Services

### 1. Enable Authentication Providers
1. In the left sidebar of the Firebase Console, go to **Build** > **Authentication**.
2. Click **Get started**.
3. Under the **Sign-in method** tab, enable the following providers:
   * **Email/Password**:
     * Click **Email/Password**, toggle **Enable**, and click **Save**.
   * **Google**:
     * Click **Add new provider** and choose **Google**.
     * Toggle **Enable**.
     * Choose a project support email from the dropdown list.
     * Click **Save**.

### 2. Enable Cloud Firestore Database
1. Go to **Build** > **Firestore Database** in the left sidebar.
2. Click **Create database**.
3. Select a location closest to your users.
4. Start in **Production mode**.
5. Click **Create** and wait for the database to provision.

---

## Step 3: Install Firebase & FlutterFire CLI

Open your terminal (PowerShell, Command Prompt, or Git Bash) and run the following setup commands:

1. **Install the Firebase CLI** globally:
   ```bash
   npm install -g firebase-tools
   ```
2. **Log into Firebase** via your web browser:
   ```bash
   firebase login
   ```
3. **Activate the FlutterFire CLI** globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```
   * *Note: If you receive a warning about the PATH environment variable, add the directory shown in the terminal output to your system's environment variables.*

---

## Step 4: Configure FlutterFire in Your App

Navigate to the project root directory in your terminal and run the configuration script:

```bash
flutterfire configure
```

### Prompt Responses:
1. Select the Firebase project `tickit-<unique-id>` you created in Step 1.
2. Select the platforms you want to support (e.g., select `android` using Spacebar, and `web` or `ios` if you wish to support them).
3. Press **Enter**.

This command will:
* Register your app with Firebase.
* Automatically generate `lib/firebase_options.dart` containing all environment keys.
* Create and place configuration files (`google-services.json` for Android) in the respective native directories.

---

## Step 5: Android-Specific Configuration for Google Sign-In

Google Sign-In on Android requires registering your local keystore's SHA-1 fingerprint in the Firebase Console.

### 1. Retrieve the SHA-1 Fingerprint
Run the following command in your terminal from the project root:
```bash
cd android
./gradlew signingReport
```
Look for the **`debug`** variant block in the output. It should look like this:
```text
Variant: debug
Config: debug
Store: C:\Users\aetes\.android\debug.keystore
Alias: AndroidDebugKey
SHA-1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```
Copy the **SHA-1** fingerprint value.

### 2. Add SHA-1 to Firebase Console
1. In the Firebase Console, click the gear icon (⚙️) next to **Project Overview** in the left sidebar and select **Project settings**.
2. Scroll down to the **Your apps** section and select your **Android app** (`com.example.tick_it`).
3. Click **Add fingerprint**.
4. Paste the copied **SHA-1** key and click **Save**.

---

## Step 6: Set Firestore Security Rules

To protect your users' data and restrict users to only seeing/writing their own tasks:

1. In the Firebase Console, navigate to **Firestore Database** > **Rules** tab.
2. Replace the existing rules with the following:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       
       // Match user profiles
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
         
         // Match tasks inside user profiles
         match /tasks/{taskId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
   }
   ```
2. Click **Publish**.

---

## Step 7: Update Your Flutter Code

Once the configuration is generated, you must enable the Firebase initialization code in [main.dart](lib/main.dart).

1. Open `lib/main.dart`.
2. Uncomment the Firebase options imports and initializations.
3. Your main method should look like this:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase with auto-generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TickItApp());
}
```

---

## Step 8: Build and Run

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Build and run the app:
   ```bash
   flutter run
   ```

---

## Troubleshooting Tips

* **Google Sign-In fails immediately (Status Code 10/12500)**: This is almost always due to a missing or mismatched SHA-1 fingerprint in the Firebase Console settings. Double check that the SHA-1 key added matches the keystore used to sign the build running on your device.
* **Firestore Permission Denied**: Verify that the Firestore rules match your collection paths exactly. Your code uses the path `users/{uid}/tasks`.
* **Gradle issues after configuration**: If gradle errors out, try cleaning the project cache:
  ```bash
  flutter clean
  flutter pub get
  ```
