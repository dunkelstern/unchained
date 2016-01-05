# Installation

Installation is done in 3 relatively simple steps:

1. Install Swift
2. Install external dependencies
3. Install socket support library

## Install Swift

Go to the [Swift Download Page](https://swift.org/download/) and fetch a Swift snapshot to install on your development machine. If you want to deploy to a Linux box you'll need a working Linux installation as cross compilation is currently not supported by Swift.

Just follow the installation instructions on the download page.

As we have no method of disabling targets in the Swift package manifests you'll need the [XCTest framework](https://github.com/apple/swift-corelibs-xctest) from Apple installed, just follow the instructions in the readme for Linux. This is not working for OSX at the time of this writing, I'll submit a pull request for that later.

## External dependencies

On Linux make sure `clang`, `libpcre`, `libbsd` and `libBlocksRuntime` are installed by running the following command (Ubuntu 15.10):

~~~bash
sudo apt-get install clang libbsd-dev libpcre3-dev libblocksruntime-dev
~~~

On OSX you'll need the Xcode command line tools and just `libpcre`, fetch it with [Homebrew](http://brew.sh):

~~~bash
xcode-select --install
brew install libpcre
~~~

## Socket support library

You'll need a small Socket abstraction library installed for everything to work. Get it from Github, and compile:

~~~bash
git clone https://github.com/dunkelstern/libUnchainedSocket.git
cd libUnchainedSocket
make
sudo make install
~~~

This will copy the library to `/usr/local/lib` and the corresponding headers to `/usr/local/include/unchainedSocket` for Swift to pick up later.

## Read on

Read on in [3. Configuration](config.html).