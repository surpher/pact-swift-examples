# macOS Example using Carthage

## Disclaimer

The code in this repository does not represent good programming practices!

This repository is used solely to demonstrate the minimal effort required to demonstrate how to set up and use [`PactSwift`](https://github.com/surpher/PactSwift) framework.

----

## Prepare dependencies

Add [`PactSwift`](https://github.com/surpher/PactSwift) to your `Cartfile` :

	github "surpher/PactSwift" "master"

_set version or branch - this one uses branch due to framework still being actively developed without a release version_

Build [`PactSwift`](https://github.com/surpher/PactSwift) as dependency in your terminal:

	carthage update --platform macos --no-use-binaries --cache-builds

## Xcode setup

[`PactSwift`](https://github.com/surpher/PactSwift) is a testing framework! Do not embed this framework into your deployable app bundle!

Your app target, ideally, should not know about [`PactSwift`](https://github.com/surpher/PactSwift) at all!

### Setup Build Phases

`Test Target > Build Settings > Link Binary With Libraries > Add Other > Add Files...`  
Find your Carthage folder, `./Build/macos/` and select `PactSwift.framework` to link it:

![link binary with libraries](../Pact-iOS-Example/res/01_link_binary_with_libraries.png)

... Or drag and drop the framework into the Build Phase.

### Setup Framework Build Settings

1. In `Test Target > Build Settings` add `$(PROJECT_DIR)/Carthage/Build/iOS` (non-recursive) to `Framework Search Paths` configuration key.

![set framework search paths](../Pact-iOS-Example/res/02_framework_search_paths.png)

2. In `Test Target > Build Settings` Add `$(FRAMEWORK_SEARCH_PATHS)` to `Linking > Runpath Search Paths`

![set runpath search paths](../Pact-iOS-Example/res/03_runpath_search_paths.png)

### Set destination dir

Edit scheme and add `PACT_DIR` environment variable with `dir` where you want your Pact contracts to be written to:

![set destination dir](../Pact-iOS-Example/res/04_destination_dir.png)

**NOTE:** If this environment variable is not set, the default dir [`PactSwift`](https://github.com/surpher/PactSwift) writes the contract to is `/tmp/pacts`.

## Run tests

1. Target `Pact-iOS-FAILING-ExampleTest` will fail with 4 tests and show the benefits of testing your "real" API Client implementation.

2. Target `Pact-iOS-ExampleTests` will pass all tests and as a result a _[consumer_name]-[provider_name].json_ (eg: `passing-app-test-provider.json`) Pact Contract file is generated in `$(PROJECT_DIR)/tmp/pacts` folder.

## Notes

Repeat for any test target that does Pact testing.

## References

[PACT Foundation](https://docs.pact.io)