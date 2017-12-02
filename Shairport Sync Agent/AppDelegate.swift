//
//  AppDelegate.swift
//  Shairport Sync Agent
//
//  Created by Tobias Strobel on 27.11.17.
//  Copyright © 2017 Tobias Strobel. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var statusMenuController: StatusMenuController!
	
	var shairportSyncAgent: Agent?
	
	let url = URL(fileURLWithPath: "/usr/local/bin/shairport-sync")
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let userInformationCenter = UserInformationCenter()
		let agent = Agent(self.url)
		agent.addStandardOutputCallback { data -> Void in
			if let dataString = String(bytes: data, encoding: String.Encoding.utf8) {
				print("Out: " + dataString)
			}
		}
		agent.addStandardErrorCallback { data -> Void in
			if let dataString = String(bytes: data, encoding: String.Encoding.utf8) {
				print("Error: " + dataString)
			}
		}
		self.statusMenuController.shairportSyncAgent = agent
		userInformationCenter.shairportSyncAgent = agent
		agent.start()
		self.shairportSyncAgent = agent
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		self.shairportSyncAgent!.stop()
	}
	
}
