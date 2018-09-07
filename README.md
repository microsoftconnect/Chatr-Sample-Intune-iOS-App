# Chatr - An Intune MAM iOS SDK Example (Swift)
This application is a demonstatrion of the [Microsoft Intune SDK for iOS](https://github.com/msintuneappsdk/ms-intune-app-sdk-ios). A developer guide to the SDK is available [here](https://docs.microsoft.com/en-us/intune/app-sdk-ios). This project implements some commonly used features so developers integrating their apps with the SDK have an example to follow. 

Chatr offers a simple messaging interface allowing users to send messages, print and save conversations to their local device. It uses the [Azure Active Directory Authentication Library](https://github.com/AzureAD/azure-activedirectory-library-for-objc) to authenticate users.

## Steps to run the app
In order to deploy this sample you will need an Intune subscription. Free trials are sufficient for this demo.

### Step 1: Setting up Intune
You will need at least one user assigned to a user group. You can see how to create new users [here](https://docs.microsoft.com/en-us/intune/users-add) and user groups [here](https://docs.microsoft.com/en-us/intune/groups-add). Be sure to assign Intune licenses to your users [here](https://docs.microsoft.com/en-us/intune/get-started-users).

### Step 2: Registering the app with Azure Active Directory
You will need to configure a few values to properly register your app with Azure Active Directory.
#### Register the client app
1. Sign in to the [Azure Portal](https://portal.azure.com/)
1. In the **Azure Active Directory** pane, click on **App registrations** and choose **New application registration**.
1. Enter a friendly name for the application, for example 'Chatr' and select 'Native' as the *Application Type*.
1. For the *Redirect URI*, enter `<scheme>://<bundle_id>`, for chatr this is `chatr://Intune.chatr` 
1. Click **Create** to create the application.
1. In the succeeding page, Find the *Application ID* value and record it for later. You'll need it to update the value within the code in the `ObjCUtils.m` file for the *clientID* variable.  
1. Then click on **Settings**, and choose **Properties**.
1. Configure Permissions for your application.
   1. In the Settings menu, choose the 'Required permissions' section.
   1. Click on **Add**, then **Select an API**, and type `Microsoft Mobile Application Management` in the textbox.
   1. Then, click on  **Select Permissions** and select the permissions:
      1. Check the "Read and Write the User’s App Management Data" permission.
      1. Press **Select** at the bottom of the pane, and then **Done** in the "Add API access pane".
	 1. After adding the above permissions, click the **Grant permissions** button towards the top of the 'Required permissions' pane and agree to the prompt to update the app permissions.
	
#### Configure the sample to use your AD tenant
Values need to be changed in `Chatr/ObjCUtils.m` and `Info.plist`. See these files for more details. Note that the *client ID* is the same as the *Application ID* you recorded earlier.

### Step 3: Create and Deploy App Protection Policy (APP)
To enable MAM without device enrollment (MAM-WE), we must create a new App Protection Policy with Intune. Instructions for creating a and deploying a new APP can be found [here](https://docs.microsoft.com/en-us/intune/app-protection-policies). You may target a line-of-business app in one of two ways.
1. If you require your app to be available for download via the Intune Company Portal, follow these [instructions](https://docs.microsoft.com/en-us/intune/lob-apps-ios).
1. If you're app will not be deployed via the Company Portal or it is in development and requires testing of APP, you may follow the steps below: 
   1. From the APP you created earlier, click on **Select required apps**.
   1. At the top of the pane click **More apps** and scroll to the bottom of the pane.
   1. Enter the Bundle ID of your app and click **Add**. This can be found your apps's `Info.plist` file. This app's Package ID is `Intune.chatr`.
	 1. Hit **Select** at the bottom of the "Apps" pane.
	 1. Click the **Settings** button in the "Add a policy" pane and set the policy settings you would like to apply to a user group for your app.
	 1. Once you have selected the settings click **Okay** at the bottom of the pane and then click **Create** at the bottom of the "Add a policy" pane. Your app should now appear in the "App protection policies" pane.
    
### Step 4: Launch the App & Sign-In
Chatr should now be properly configured with Intune and Azure AD. When prompted to sign in, use one of the users in the group used in Step 3. 
## Relevant Files
- `Chatr/ObjCUtils.m` contains the bulk of ADAL authentication logic, MAM account registration, and communication with the MAM service. 
- `Chatr/ViewController.swift` contains calls for log in and log out. 
- `Chatr/chatr-Bridging-Header.h` allows the swift app to interact with objective C.
- `Chatr/ChatPage.swift` checks if the MAM service allows saving to Local Drive is allowed for the user.  
	

