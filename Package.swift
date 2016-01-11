//
//  Package.swift
//  Unchained
//
//  Created by Johannes Schriewer on 2016-01-03.
//  Copyright © 2016 Johannes Schriewer. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "Unchained",
	targets: [
	 	Target(name:"UnchainedTests", dependencies: [.Target(name: "Unchained")]),
	 	Target(name:"UnchainedDemo", dependencies: [.Target(name: "Unchained")]),
        Target(name:"Unchained")
	],
	dependencies: [
        .Package(url:"https://github.com/dunkelstern/Adler32.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedString.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedDate.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedFile.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedLogger.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedIPAddress.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/libUnchainedSocket.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/twohundred.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/DEjson.git", majorVersion: 1),
        .Package(url:"https://github.com/dunkelstern/Base64.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/QuotedPrintable.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/pcre.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/SwiftyRegex.git", majorVersion: 1),
        .Package(url:"https://github.com/dunkelstern/PathKit.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/Stencil.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedUUID.git", majorVersion: 0)
    ]
)

#if os(Linux)
    package.dependencies.appendContentsOf([
        .Package(url:"https://github.com/dunkelstern/BlocksRuntime.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedGlibc.git", majorVersion: 0)
    ])
#endif