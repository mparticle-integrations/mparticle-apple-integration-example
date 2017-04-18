# mParticle Apple Kit Library

A kit is an extension to the core [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk). A kit works as a bridge between the mParticle SDK and a partner SDK. It abstracts the implementation complexity, simplifying the implementation for developers.

A kit takes care of initializing and forwarding information depending on what you've configured in [your app's dashboard](https://app.mparticle.com), so you just have to decide which kits you may use prior to submission to the App Store. You can easily include all of the kits, none of the kits, or individual kits – the choice is yours.

[![CocoaPods compatible](http://img.shields.io/badge/CocoaPods-compatible-brightgreen.png)](https://cocoapods.org/?q=mparticle)


## Installation

Please refer to installation instructions in the core mParticle Apple SDK [README](https://github.com/mParticle/mparticle-apple-sdk#get-the-sdk), or check out our [SDK Documentation](http://docs.mparticle.com/#mobile-sdk-guide) site to learn more.


## Create Your Own Integration

Detailed instructions on how to implement your own integration with the mParticle Apple SDK can be found [here](https://github.com/mparticle-integrations/mparticle-apple-integration-example/wiki/Kit-Integration-Development).

## Deep-linking

Call the mParticle SDK `checkForDeferredDeepLinkWithCompletionHandler:` method to retrieve the respective information.

The completionHandler will get passed the linkInfo dictionary with the following data.

```json
{
	"destinationURL" : <the destination url>,
	"clickedURL", <the clicked url>
}

```

Add in the following to store the clicked url on app load.

```objective-c
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    [[MParticle sharedInstance] continueUserActivity:userActivity restorationHandler:restorationHandler];
    
    return YES;
}
```

## Support

Questions? Give us a shout at <support@mparticle.com>


## License

This mParticle Apple Kit is available under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). See the LICENSE file for more info.
