//
//  UserInformationCenter.swift
//  Shairport Sync Agent
//
//  Created by Tobias Strobel on 27.11.17.
//  Copyright © 2017 Tobias Strobel. All rights reserved.
//

import AppKit

class UserInformationCenter {
	
	var shairportSyncAgent: Agent? {
		didSet {
			self.shairportSyncAgent!.addTerminationCallback(self.shairportSyncDidTerminate)
			self.shairportSyncAgent!.addStartErrorCallback(self.shairportSyncStartErrorDidOccure)
		}
	}
	
	func alert(messageText: String, informativeText: String) {
		let alert = NSAlert()
		alert.messageText = messageText
		alert.informativeText = informativeText
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}
	
	func notify(title: String, informativeText: String) -> Void {
		let notification = NSUserNotification()
		notification.title = title
		notification.informativeText = informativeText
		notification.soundName = NSUserNotificationDefaultSoundName
		NSUserNotificationCenter.default.deliver(notification)
	}
	
	func shairportSyncDidTerminate(terminationStatus: Int32) {
		self.alert(
			messageText: "Shairport Sync terminated unexpectadly.",
			informativeText: "Shairport Sync terminated with termination status: " + String(terminationStatus)
		)
	}
	
	func shairportSyncStartErrorDidOccure(error: Error) {
		self.alert(
			messageText: "There was a problem running Shairport Sync:",
			informativeText: error.localizedDescription
		)
	}
	
}
