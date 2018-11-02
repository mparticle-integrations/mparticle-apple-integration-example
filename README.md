## FollowAnalytics Kit Integration

This repository contains the [FollowAnalytics](https://www.followanalytics.com/) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Adding the integration

1. Add the kit dependency to your app's Podfile or Cartfile:

    ```
    pod 'mParticle-FollowAnalytics', '~> 1.2'
    ```

    OR

    ```
    github 'mparticle-integrations/mparticle-apple-integration-followanalytics' ~> 1.2.3
    ```

2. Please initialize the [FollowAnalytics iOS SDK](https://dev.followanalytics.com/sdks/ios/documentation/#integration) before initializing the mParticle SDK.

3. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { FollowAnalytics }"` in your Xcode console

> (This requires your mParticle log level to be at least Debug)

4. Reference mParticle's integration docs below to enable the integration.

### Documentation

[Example integration](https://docs.mparticle.com/integrations/FollowAnalytics/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
