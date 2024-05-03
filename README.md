# Nearby
Trace the Footsteps of History Nearby

This repository contains the source code for the Nearby iOS app, which showcases interesting facts about locations near the user.

## Prerequisites

Before you begin, ensure you have met the following requirements:
- You have installed [Xcode](https://developer.apple.com/xcode/) (version 11.0 or later).
- You have a Mac with macOS Catalina or later.
- You have a valid Apple developer account to run the app on a physical device.

## Cloning the Repository

To clone the repository using HTTPS, run the following command:

```bash
git clone https://github.com/SaiSamarth123/Nearby.git
```

To clone using SSH, use:

```bash
git clone git@github.com:SaiSamarth123/Nearby.git
```

After cloning the project, navigate to the project directory:

```bash
cd Nearby
```

## Opening the Project in Xcode

Open the project by double-clicking the `Nearby.xcodeproj` file or open Xcode and select `File > Open` and navigate to your project folder to select the project file.

## Running the App on a Simulator

To run the app on a simulator, follow these steps:
1. Open the project in Xcode.
2. Select your target device from the top device toolbar.
3. Click the `Run` button or press `Cmd + R` to build and run the project.

The app will launch in the simulator you selected.

## Running the App on a Physical Device

To run the app on a physical iPhone, you need to do some additional setup:
1. Connect your iPhone to your Mac via a USB cable.
2. Unlock your iPhone and trust the computer (if not already trusted).
3. In Xcode, select your iPhone from the top device toolbar (you may need to wait a moment for Xcode to recognize your device).
4. Go to `Xcode > Preferences > Accounts` and ensure your Apple developer account is added.
5. Select the project in the navigator, go to the `Signing & Capabilities` tab, and select your Team. Xcode might prompt you to fix issues related to provisioning profiles.
6. Click the `Run` button or press `Cmd + R` to build and run the project on your iPhone.

You might need to go to `Settings > General > Device Management` on your iPhone and trust the developer certificate for your Apple ID before the app will run.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
