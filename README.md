## Swrve Kit Integration

This repository contains the [Swrve](https://www.swrve.com/) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Adding the integration

1. Add the kit dependency to your app's Podfile or Cartfile:

    ```
    pod 'Swrve-mParticle', '~> 1.0'
    ```

    OR

    ```
    github 'mparticle-integrations/mparticle-apple-integration-swrve' ~> 1.0
    ```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { Swrve }"` in your Xcode console 

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

### Documentation

[Swrve integration](https://docs.mparticle.com/integrations/swrve/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
