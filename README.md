# mac_admin
Hi! I'm a Mac admin based in Austin, TX and I've uploaded some helpful scripts and configuration profiles compatible with macOS High Sierra. You may freely use or modify anything I upload, but please check out the MIT license.

__This page will be updated and maintained on a regular basis with additional profiles and scripts.__

__Coming soon: Download link for the macOS 10.13.3 installer__

## Pkgs

* skipprivacy_signed.pkg
  * Add this pkg to your existing imaging workflow (MDM solution/Munki/NetInstall/AutoDMG)
  * Skips the Data & Privacy screen introduced in 10.13.4
  * Pkg has a Product ID and is signed

## Scripts

The scripts folder contains helpful scripts compatible with macOS High Sierra.

* create_admin_user: use `sysadminctl` to create an admin account that is granted a secureToken. 
  * The script assumes the current logged in user is an admin with `secureToken` (like a chain-of-trust system)
  * It uses the password passthrough option `-` to avoid plaintext passwords in the script.
  * __You cannot automate this script by incorporating into a .pkg and have it run as `root`__ There must be physical user interaction by the admin via the GUI or CLI for High Sierra to grant `secureToken`. The `root` user does not have `secureToken` therefore it cannot issue that attribute to a new user account.
  * I create a pkg that pre-stages the script `/path/to/script.command`
  * Use a simple LoginHook with your MDM provider, or incorporate into NoMAD using the `SignInCommand` key in a configuration profile
  * Example: `open /path/to/script.command`
  * macOS grants `secureToken` under these scenarios:
    * You have a DEP-enrolled Mac, and your MDM service supports user creation during MDM PreStage enrollment __(the only truly automated option)__
    * In the GUI, either in macOS Setup Assistant or System Preferences
    * Using `sysadminctl` with the `interactive` argument

* admin_pwreset: Change an unknown admin password in macOS High Sierra

* outlook_timezone: If a user is unable to resolve time zone mismatch errors in Microsoft Outlook 2016. I incorporate this script into a pkg to run as `root`. You may have to add `sudo` in your environment.

* startosinstall_usbdisk: Place a macOS 10.13.4 (or later) installer on an external USB disk and run this command to begin an erase & install of macOS. 
  * If you have any additional pkgs, add them in the same directory. 
  * Target must be running 10.13 (or later)
  * Not a bootable installer. Apple needs to update `createinstallmedia` to support additional flags, like:
    * `--eraseinstall`
    * `--agreetolicense`
    * `--nointeraction`
    * `--installpackage` (can be used multiple times, but keep the total number of pkgs and file sizes to a minimum)
    * `--newvolumename`

## Munki_pkgsinfo

I use Munki to deploy apps and custom pkgs at my organization. Munki supports `startosinstall` to re-image already-deployed Macs.

* An admin (or the user) visits Managed Software Center and downloads the macOS installer as an `OnDemand` `optional_install`
* Munki supports the `startosinstall` command, I add additional flags like...
  * `--eraseinstall`
  * `--agreetolicense`
  * `--nointeraction`
  * `--installpackage` (can be used multiple times, but keep the total number of pkgs and file sizes to a minimum)
  * `--newvolumename`

## Profiles

The profiles folder contains helpful mobileconfig files for use with your MDM service. The `PayloadRemovalDisallowed` key may be set to `-bool` value `true` or `false` depending on the profile. Please adjust the profile removal restrictions as needed when uploading to your MDM service.

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
   * Volume __(macOS hides this by default)__
   * VPN __(macOS hides this by default)__

* enable_firewall: enforces the firewall, installed apps are able to receive incoming connections
