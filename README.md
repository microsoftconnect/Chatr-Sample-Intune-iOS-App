# Chatr - An Intune MAM iOS SDK Example (Swift)
This application is a demonstration of the [Microsoft Intune SDK for iOS](https://github.com/msintuneappsdk/ms-intune-app-sdk-ios). A developer guide to the SDK is available [here](https://docs.microsoft.com/en-us/intune/app-sdk-ios). This project implements some commonly used features so developers integrating their apps with the SDK have an example to follow. 

Chatr offers a simple messaging interface allowing users to send messages, print, and save conversations to their local device. It uses the [Azure Active Directory Authentication Library](https://github.com/AzureAD/azure-activedirectory-library-for-objc) to authenticate users.

## Steps to run the app
In order to deploy this sample you will need an Intune subscription. Free trials are sufficient for this demo.

### Step 1: Setting up Intune
You will need at least one user assigned to a user group. You can see how to create new users [here](https://docs.microsoft.com/en-us/intune/users-add) and user groups [here](https://docs.microsoft.com/en-us/intune/groups-add). Be sure to assign Intune licenses to your users [here](https://docs.microsoft.com/en-us/intune/get-started-users).

### Step 2: Create and Deploy App Protection Policy (APP)
To enable MAM without device enrollment (MAM-WE), we must create a new App Protection Policy with Intune. Instructions for creating a and deploying a new APP can be found [here](https://docs.microsoft.com/en-us/intune/app-protection-policies). You may target a line-of-business app in one of two ways.
1. If you require your app to be available for download via the Intune Company Portal, follow these [instructions](https://docs.microsoft.com/en-us/intune/lob-apps-ios).
1. If your app will not be deployed via the Company Portal or it is in development and requires testing of APP, you may follow the steps below: 
   1. From the APP you created earlier, click on **Select required apps**.
   1. At the top of the pane click **More apps** and scroll to the bottom of the pane.
   1. Enter the Bundle ID of your app and click **Add**. This can be found your apps's `Info.plist` file. This app's Package ID is `Intune.chatr`.
	 1. Hit **Select** at the bottom of the "Apps" pane.
	 1. Click the **Settings** button in the "Add a policy" pane and set the policy settings you would like to apply to a user group for your app.
	 1. Once you have selected the settings click **Okay** at the bottom of the pane and then click **Create** at the bottom of the "Add a policy" pane. Your app should now appear in the "App protection policies" pane.
    
### Step 3: Launch the App & Sign-In
Chatr should now be properly configured with Intune. When prompted to sign in, use one of the users in the group used in Step 2. 
## Relevant Files
- `Chatr/EnrollmentDelegate.m` contains logic for enrolling/unenrolling and registering/deregistering the application with Intune MAM on behalf of the user.
- `Chatr/PolicyDelegate.m` contains logic for wiping data for a specific user and restarting the application when MAM policies are received for the first time.
- `Chatr/KeychainManager.swift` contains logic for adding, updating, and removing user data in the keychain.
- `Chatr/ViewController.swift` contains calls for log in.
- `Chatr/chatr-Bridging-Header.h` allows the Swift app to interact with Objective-C.
- `Chatr/ChatPage.swift` 
    - Registers the application to receive notifications when an IT administrator updates app configuration or protection policies
    - Displays, clears, and saves chat page messages
    - Presents the user with a print preview of chat page messages
