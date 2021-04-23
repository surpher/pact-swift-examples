# macOS (SPM) Example

## Disclaimer

The code in this repository does not represent good programming practices!

This repository is used solely to demonstrate the minimal effort required to set up and use [`PactSwift`](https://github.com/surpher/PactSwift) framework.

----

## ⚠️ Note

Due to the way SPM works with binaries and size of the binaries, we wanted to avoid resorting to Git-LFS and cost of GitHub LFS.

This drove the decision to make your compiler do the work of compiling the Rust codebase of [`libpact_mock_server_ffi`][pact-reference-rust]. First time you will run the tests it will take a lot longer to compile the project. Unless Rust codebase changes, Rust library will not be recopiled and subsequent builds will not take as long.

## Using in CLI/CI/CD?

Maybe you can use [`build-spm-dependency`][pactswift-scripts-buildphases-spm] script for some inspiration?
