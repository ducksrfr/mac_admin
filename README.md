# ** New ** FileVault Password Mismatch Fix for Mojave
Hi! I'm a Mac admin based in Austin, TX and I've uploaded some helpful scripts and configuration profiles compatible with macOS High Sierra and Mojave. You may freely use or modify anything I upload.

### Resolve an out-of-sync FileVault password with mobile AD user accounts
* There is a major bug in Mojave with AD-bound mobile user accounts. If a user's password is reset off of the Mac (like in Active Directory, Okta, or an AD-bound Windows PC) the FileVault password is never updated to reflect the password change.
* Users may report that their Keychain or account password at the login screen alternates between the old and new/current network password based on whether they are connected to the corporate network.
* A simple restart does not resolve the mismatched FileVault password
* `Mojave_FileVault_Sync.sh` in the scripts folder revokes and reissues a Secure Token, then updates the FileVault preboot volume
* I use a [LAPS script](https://github.com/ducksrfr/LAPSforMac) in a Jamf extended attribute at my org, so this script also pulls that password value for use with `sysadminctl`
* Members of the MacAdmins Slack report that Apple has acknowledged the issue, however a resolution date is unknown. The issue is still present as of 10.14.3.

### Mojave: Privacy Preferences Policy Control (TCC) profiles

* In macOS Mojave a user might encounter new privacy permission pop-ups when they launch apps like Microsoft Office, Parallels, Citrix, or TeamViewer. 
* You can find more information about the PPPC profiles from Apple <https://help.apple.com/deployment/mdm/#/mdm38df53c2a> 
* My profiles tend to focus on granting access to:
  * `SystemPolicyAllFiles`
  * `AppleEvents`
  * `Accessibility`
* You cannot pre-approve Location Services, Microphone, or Camera access.

### Scripts

The scripts folder contains helpful scripts compatible with macOS Mojave and High Sierra.

* **New** Local_pw_expiration
   * If your organization is using a configuration profile to enforce a local password expiration policy, then a user doesn't receive any proactive notification that their password is nearing expiration.
   * This script pulls the value from a [Jamf extended attribute](https://github.com/jamf/Current-User-Password-Age) (which contains the password age) and based on that value presents a "change password" warning dialogue to the user.
   * If you're not using Jamf, you can modify the script to pull the password age locally. Find the value in epoch time: `/usr/bin/dscl . -read /Users/$localUser accountPolicyData | /usr/bin/awk -F'<real>|</real>' '{print $2}' | tail -4`
   * If the user decides to reset their password, the Users & Groups pref pane will launch to allow the user to change their password.
   * This script purposely does not use `dscl` to change the password, because that causes isses with secureToken in macOS High Sierra and Mojave
   * I'm currently testing a revised version with `sysadminctl` that will respect your org's new password complexity policy 

* resetTCC_mic_camera
  * Resets the camera and microphone properties in the TCC database
  * Useful if an end user unintentionally denies access to the camera or microphone in a chat app like Skype, Slack, WebEx, or Lifesize.

* **Updated** create_admin_user: updated script with interactive `osascript` prompts to create a new user account with `sysadminctl`

* **Updated** admin_pwreset: Reset a user account password in High Sierra
  * updated script with interactive `osascript` prompts to reset a user password using `sysadminctl`

* outlook_timezone: If a user is unable to resolve time zone mismatch errors in Microsoft Outlook.

### Profiles

The profiles folder contains helpful mobileconfig files for use with your MDM service. The `PayloadRemovalDisallowed` key may be set to `-bool` value `true` or `false` depending on the profile. Please adjust the profile removal restrictions as needed when uploading to your MDM service.

* Hide 32-bit Alerts: suppresses the 32-bit compatibility warnings for legacy software in High Sierra and Mojave

* Suppress secureToken Window: suppresses the secureToken activation window that appears when an Active Directory-bound account signs into the Mac for the first time. Helpful for loaner Macs or computer lab environments

* Skip Choose Your Look: skips the Setup Assistant screen for choosing between Light and Dark mode in Mojave

* Skip Privacy Warning: skips the Setup Assistant screen for Data & Privacy in High Sierra and Mojave

* block_macosbeta: Prevents users from installing macOS beta releases

* chrome_settings: Sets some basic Chrome browser settings including:
  * preset bookmarks folder on bookmarks toolbar
  * preload Chrome extensions
  * set Java and Flash URL exceptions
  * set homepage
  * set first run tabs
  * previous versions of this profile set Chrome as the default browser, however in macOS High Sierra the user will still encounter default browser confirmation alerts regardless if that specific key is preconfigured in a profile
  
* Multiple Microsoft Office profiles: Settings to reduce the number of dialog windows need to configure a user account if your org is using Office 365. 
  * Suppresses "new feature" alerts & autodiscover auto-acceptance alerts. 
  * Suppresses user requests for diagnostic info. 
  * Sets the default save location to a "local" Mac location, and not OneDrive.  

* delay_updates: Delay macOS software updates by 30 days. Apple has the ability to bypass this restriction to push critical security patches.

* disable_icloud_sync: Allows users to enable iCloud Drive on their Mac, however the iCloud Documents & Desktop sync feature is disallowed

* disable_pw_change: If your users should reset their local Mac passwords using NoMAD, this restriction disables the Change Password button in System Preferences. Admins may still reset user passwords using the `sysadminctl` command or via your MDM service

* expand_dialogs: Forces the expanded save and print dialog windows in macOS

* kernelext_symantec: Allows macOS to load kernel extensions for Symantec Anti Virus 14

* nomad_example: template for deploying NoMAD in your environment

* block_profiles: Prevents users from clicking the Profiles pref pane in System Preferences

* lock_screen: multiple settings for the lock and login screens
  * sets a lock screen message (and prevents users from changing it)
  * Allows Touch ID and auto unlock with Apple Watch
  * Disables the guest account
  * Enforces fast-user switching
  * Requires a user password 5 seconds after screensaver or sleep
  * Shows the Sleep, Restart, and Shutdown buttons at the lock screen
  * Disables auto user login
  * Presents username and password fields instead of user account icons at the lock screen. 
    * Note: The FileVault login screen will always show user account icons
 
 * menubar_icons: Hide the Siri button in the menu bar, and __always show:__
   * AirPlay
   * Wifi
   * User's full name (for fast-user switching)
   * Battery icon with percentage
   * Bluetooth __(macOS hides this by default)__
   * Clock
   * Volume __(hidden by default)__
   * VPN __(hidden by default)__

* enable_firewall: enforces the firewall, installed apps are able to receive incoming connections

### Munki_pkgsinfo

I use Munki to deploy apps and custom pkgs at my organization. Munki supports `startosinstall` to re-image already-deployed Macs.

* An admin (or the user) visits Managed Software Center and downloads the macOS installer as an `OnDemand` `optional_install`
* Munki supports the `startosinstall` command, I add additional flags like...
  * `--eraseinstall`
  * `--agreetolicense`
  * `--nointeraction`
  * `--installpackage` (can be used multiple times, but keep the total number of pkgs and file sizes to a minimum)
  * `--newvolumename`
