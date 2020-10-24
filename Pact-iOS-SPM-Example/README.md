# iOS (SPM) Example

## Disclaimer

The code in this repository does not represent good programming practices!

This repository is used solely to demonstrate the minimal effort required to set up and use [`PactSwift`](https://github.com/surpher/PactSwift) framework.

----

## ⚠️ Note

Due to the way SPM works with binaries and size of the binaries, we wanted to avoid resorting to Git-LFS and cost of GitHub LFS.

This drove the decision to make your compiler do the work of compiling the Rust codebase of [`libpact_mock_server_ffi`][pact-reference-rust]. First time you will run the tests it will take a lot longer to compile the project. Unless Rust codebase changes, Rust library will not be recopiled and subsequent builds will not take as long.

## Using in CLI/CI/CD ?

Maybe you can use [`build-spm-dependency`][pactswift-scripts-buildphases-spm] script for some inspiration?

## Installation

### Add PactSwift as a Swift Package

Make sure to add the package to your test target.

<img src="Resources/Assets/00-swift-package.png" width="400" alt="Swift package" />

### Setup the Build Step

Add a Build Step script to compile `libpact_mock_server_ffi` binary for your system. It will replace the fake one in the PactSwift package.
The source code for `libpact_mock_server_ffi` is in the PactSwift git submodule `PactSwift/Submodules/pact-reference/rust/libpact_mock_server_ffi`.

<img src="Resources/Assets/01-build-step.png" width="400" alt="Build step" />

### Edit the search paths in build settings

Add `$BUILD_DIR/../../SourcePackages/checkouts/PactSwift/Resources` -recursive to `Library Search Paths` and `Frameworks Search Paths` in your test target's build settings.

<img src="Resources/Assets/02-library-search-path.png" width="400" alt="Swift package" />

## References

[PACT Foundation](https://docs.pact.io)

[pactswift-scripts-buildphases-spm]: https://github.com/surpher/PactSwift/tree/master/Scripts/BuildPhases/build-spm-dependency
[pact-reference-rust]: https://github.com/pact-foundation/pact-reference/tree/master/rust