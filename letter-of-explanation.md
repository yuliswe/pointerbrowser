### NSAllowArbitraryLoad (Pointer v1.1)

Hello App Review Team,

This is a letter of explanation of why we need to enable NSAllowArbitraryLoad for our app. We will explain why Pointer requires HTTP connection to function and ask the review team to make an exception for our app.

We understand that in order to improve user experience, Apple encourages developers to avoid HTTP protocol whenever possible. We agree this is a beneficial policy for apps that connect to their own servers. However, because our app is a web browser, we have no control over the services our users need to visit. We believe disabling HTTP connection does not constitute a good user experience. Many of our users are academic professionals. The websites they frequently visit include public libraries, university resources and mailing lists. Many of these sites are still hosted over HTTP. Our users would like to view and download articles on these sites.

Note that in such cases, using NSAllowArbitraryLoadInWebContent is not enough, because downloading a file via NSURLSessionDownloadTask still requires NSAllowArbitraryLoad.

Banning HTTP would make Pointer unusable. Meanwhile, we understand the dilemma. We believe in such case users should be asked to make the choice. 

Our solution is following: when users visit an HTTP URL, Pointer would display a warning telling the users that they are visiting the website using an unencrypted method, and ask them if they want to proceed. The same thing happens when a user attempts to download a file over HTTP. 

An app that does nothing is secure but useless. We need to find a middle ground between utility and security. We look forward to a day when all internet traffics are encrypted. But until then, we have to support these HTTP sites.

Cheers,

Pointer Developers

Dec 28, 2018

--------------------------------------------------------------------------------

### Rejection (Pointer v1.0.1)

Hello, 

This is our feedback for the previous rejection.

For security and performance reasons Pointer would not record all links on all webpages that you visit. To make a webpage searchable in the "Discovery" field you need to explicitly whitelist the webpage URL, or a group a webpage URL by using a wildcard pattern in the setting.

To see an example:

1. visit https://developer.apple.com/documentation/foundation?language=objc
2. click the eye icon on the upper-right corner and enable the default rule in the popup, or alternatively, add and enable a new rule "developer.apple.com/documentation/*?language=objc"
3. observe that on the left panel, the discovery section is populated with links
4. now the Discovery feature is enabled on any URL that matches the enabled rule

* Note that this whitelist is applied on the links, not on the website you visted. For example, if you enable a rule "www.google.com/*" Pointer will record links that match "www.google.com/*". However, it does not necessarily record links listed in the google search results, because websites listed in the search results do not necessarily match "www.google.com/*".

To make our advertisement more accuate, we rearranged the screenshots so that the one with discovery rule settings now appears before the ones that list wikipedia links. 

This feature is designed to replace "history search". With "discovery" the user decides what's included in the search result, which additionally includes links that you may not have visted but have seen on some other pages.

Your feedback is important to us. We can see a user getting confused by this feature not knowing how to use this. However, as the joke goes, "it's not a bug, it's a feature." In the next major release we will improve the UI to make this setting more clear and accessible to users.

For the second issue, Poninter does not share data with other apps so an app group is not necessary. We have previously disabled the App Group feature in Xcode. However, we noticed that by default Xcode leaves com.apple.security.application-groups as an empty array in the entitlement file when App Group is disabled. Following your feedback we manually removed this entry from the entitlement file.

Cheers,

Pointer Developers
