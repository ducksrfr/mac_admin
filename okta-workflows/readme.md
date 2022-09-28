### Okta Workflows Templates

You are able to download the `.flow` template files and upload them to your sandbox or production instance of Okta Workflows.

Most automations are in a parent/child flow pair. I suggest uploading all parent flows first. The Okta Workflows import tool may prompt you to select a parent flow to associate with each child flow as they are imported.

## Parent Flows

Parent flows begin with an event trigger. Some flows may have a suggested event like User Activation. Others may have a placeholder Helper Flow with a hint as to the information needed to complete the flow. 

For example: `removeFromStaticGroupParent.flow` needs the user's email address to process the remainder of both the parent and child flows. Common choices might be Okta User Activation or Okta User Deactivation.

## Child Flows

Child flows typically begin with a Helper Flow card to reference the parent flow on-demand. `reinstallJamfFrameworkParentFlow.flow` begins with a Scheduled Flow so that the automation runs on a regular basis vs on-demand.

## Connections

Action cards may require a Workflows Connection to authenticate with the Okta or Jamf APIs. Your Workflows environment may prompt you to associate Connections that you have previously configured in your org with these templates.

## Available Flows

* Remove Computers from a Static Group
* Add Computers to a Static Group
* Reinstall the Jamf Framework
* Unlock Local Mac User Account on Okta Password Reset
* Lock Devices On Okta User Deactivation
* Send Software Update MDM Command
