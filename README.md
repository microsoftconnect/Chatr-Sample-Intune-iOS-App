# Chatr - An Intune MAM iOS SDK Example (Swift)
This application is a demonstration of the [Microsoft Intune SDK for iOS](https://github.com/msintuneappsdk/ms-intune-app-sdk-ios). A developer guide to the SDK is available [here](https://docs.microsoft.com/intune/app-sdk-ios). This project implements some commonly used features so developers integrating their apps with the SDK have an example to follow. 

Chatr offers a simple messaging interface allowing users to send messages, print, and save conversations to their local device. It uses the [Azure Active Directory Authentication Library](https://github.com/AzureAD/azure-activedirectory-library-for-objc) to authenticate users.

## Steps to run the app
In order to deploy this sample you will need an Intune subscription. Free trials are sufficient for this demo.

### Step 1: Setting up Intune
You will need at least one user assigned to a user group. You can see how to create new users [here](https://docs.microsoft.com/intune/users-add) and user groups [here](https://docs.microsoft.com/intune/groups-add). Be sure to assign Intune licenses to your users [here](https://docs.microsoft.com/intune/get-started-users).

### Step 2: Create and Deploy App Protection Policy (APP)
To enable MAM without device enrollment (MAM-WE), we must create a new App Protection Policy with Intune. Instructions for creating and deploying a new APP can be found [here](https://docs.microsoft.com/intune/app-protection-policies). 
1. To create an APP targeting the Chatr sample app, click on **Create policy** in the "App protection policies" pane. 
1. In the "Create policy" pane specify the protection policy name, description, and platform. Click on **Select required apps**.
1. At the top of the pane click **More apps** and scroll to the bottom of the pane.
1. Enter the Bundle ID of your app and click **Add**. The Chatr bundle ID can be found by selecting the project file in the Xcode project explorer, selecting the chatr target, and selecting the "General" tab. This app's bundle ID is `Intune.chatr`.
1. Hit **Select** at the bottom of the "Apps" pane.
1. Click the **Settings** button in the "Create policy" pane and set the policy settings you would like to apply to a user group for your app.
1. Once you have selected the settings click **OK** at the bottom of the Settings pane and then click **Create** at the bottom of the "Create policy" pane. Your app should now appear in the "App protection policies" pane.
     
### Step 3: Create and Deploy App Configuration Policy
Instructions for creating and deploying a new App Configuration Policy can be found [here](https://docs.microsoft.com/intune/app-configuration-policies-use-ios). 
1. To create an App Configuration Policy targeting the Chatr sample app, click on **Add** in the "App configuration policies" pane. 
1. In the "Add configuration policy" pane pecify the configuration policy name and description. Under "Device enrollment type" select **Managed apps**. Click on **Select the required app**. 
1. At the top of the pane click **More apps** and scroll to the bottom of the pane.
1. Enter the Bundle ID of your app and click **OK**. The Chatr bundle ID can be found by selecting the project file in the Xcode project explorer, selecting the chatr target, and selecting the "General" tab. This app's Package ID is `Intune.chatr`.
1. Click the **Configuration settings** button in the "Add configuration policy" pane and set the key-value pair configuration you would like to apply to a user group for your app. For intance, to change the messaging group name on the Chat Page of the Chatr sample app to "Intune", you can create a configuration where the key is "GroupName" and the value is "Intune".
1. Once you have added the key-value pair configuration click **OK** at the bottom of the "Configuration" pane and then click **Add** at the bottom of the "Add configuration policy" pane. Your app should now appear in the "App configuration policies" pane.
    
### Step 4: Launch the App & Sign-In
Chatr should now be properly configured with Intune. When prompted to sign in, use one of the users in the group used in Step 2 or Step 3. 
## Relevant Files
- `Chatr/chatr-Bridging-Header.h` allows the Swift app to call the ADAL and Intune SDK APIs, which are defined in Objective-C.
- `Chatr/LoginPage.swift` contains logic for authenticating and enrolling the user with Intune.
- `Chatr/EnrollmentDelegate.swift` contains logic which responds to an Intune enrollment or unenrollment attempt.
- `Chatr/PolicyDelegate.swift` contains logic for removing data for a specific user when a selective wipe command is received from the Intune MAM service and responding to when the Intune SDK needs to restart the application.
- `Chatr/KeychainManager.swift` contains logic for adding, updating, and removing user data in the keychain.
- `Chatr/ChatPage.swift` 
    - Registers the application to receive notifications when an IT administrator updates app configuration or protection policies.
    - Contains all of the main functionality of the app.
- `Chatr/SettingsPage.swift` contains option to display the Intune Diagnostics Console, which end users can use to help IT administrators and Microsoft support diagnose issues.
