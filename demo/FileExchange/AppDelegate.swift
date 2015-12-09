//
//  AppDelegate.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Cocoa
import unchained

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        UnchainedServer(config: FileExchangeConfig()).start()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func openBrowser(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://localhost:8000")!)
    }

}

