# macOS Example

An example project demonstrating usage of [`PactSwift`](https://github.com/surpher/PactSwift) with a sandboxed macOS app.

## Disclaimer

The code in this repository does not represent good programming practices!

This repository is used solely to demonstrate the minimal effort required to set up and use [`PactSwift`](https://github.com/surpher/PactSwift) framework.

----

## Prepare dependencies

**NOTE:** The images show iOS framework. Steps to import macOS framework are identical.

Add [`PactSwift`](https://github.com/surpher/PactSwift) to your `Cartfile` :

	github "surpher/PactSwift" "master"

_set version or branch - this one uses branch due to framework still being actively developed without a release version_

Build [`PactSwift`](https://github.com/surpher/PactSwift) as dependency in your terminal:

	carthage update --platform macos --no-use-binaries --cache-builds

## Run the tests in this example project

1. `cmd + u`
2. Pact contract JSON file will be written to `~/Library/Containers/au.com.pact-foundation.Pact-macOS-Example/Data/Documents`.

## Setup for your own project

### Xcode setup

[`PactSwift`](https://github.com/surpher/PactSwift) is a testing framework! Do not embed this framework into your deployable app bundle!

Your app target, ideally, should not know about [`PactSwift`](https://github.com/surpher/PactSwift) at all!

#### Setup Build Phases

`Test Target > Build Settings > Link Binary With Libraries > Add Other > Add Files...`  
Find your Carthage folder, `./Build/macos/` and select `PactSwift.framework` to link it:

![link binary with libraries](../Pact-iOS-Example/res/01_link_binary_with_libraries.png)

... Or drag and drop the framework into the Build Phase.

#### Setup Framework Build Settings

1. In `Test Target > Build Settings` add `$(PROJECT_DIR)/Carthage/Build/iOS` (non-recursive) to `Framework Search Paths` configuration key.

![set framework search paths](../Pact-iOS-Example/res/02_framework_search_paths.png)

2. In `Test Target > Build Settings` Add `$(FRAMEWORK_SEARCH_PATHS)` to `Linking > Runpath Search Paths`

![set runpath search paths](../Pact-iOS-Example/res/03_runpath_search_paths.png)

#### Set destination dir (only non-sandboxed macOS apps)

Edit scheme and add `PACT_DIR` environment variable with `dir` where you want your Pact contracts to be written to:

![set destination dir](../Pact-iOS-Example/res/04_destination_dir.png)

**NOTE:** If this environment variable is not set, the default dir [`PactSwift`](https://github.com/surpher/PactSwift) writes the contract to is app's `NSHomeDirectory()`.

## References

[PACT Foundation](https://docs.pact.io)