//
//  StatusMenuController.swift
//  Shairport Sync Agent
//
//  Created by Tobias Strobel on 27.11.17.
//  Copyright © 2017 Tobias Strobel. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
	
	@IBOutlet var statusMenu: NSMenu!
	
	private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	
	private var startItem: NSMenuItem?
	
	private var stopItem: NSMenuItem?
	
	var shairportSyncAgent: Agent? {
		didSet {
			self.shairportSyncAgent!.addStartCallback {
				self.startItem!.isEnabled = false
				self.stopItem!.isEnabled = true
			}
			self.shairportSyncAgent!.addTerminationCallback { terminationStatus -> Void in
				self.stopItem!.isEnabled = false
				self.startItem!.isEnabled = true
			}
			self.shairportSyncAgent!.addStartErrorCallback { error -> Void in
				self.stopItem!.isEnabled = false
				self.startItem!.isEnabled = true
			}
		}
	}
	
	override func awakeFromNib() {
		self.statusItem.image = NSImage(named: NSImage.Name("Air Receiver Status Bar Icon"))
		self.statusItem.menu = self.statusMenu
		self.startItem = self.statusMenu.item(withTag: 1)!
		self.stopItem = self.statusMenu.item(withTag: 2)!
	}
	
	@IBAction func startShairportSyncClicked(_ sender: NSMenuItem) {
		self.startItem!.isEnabled = false
		self.shairportSyncAgent!.start()
	}
	
	@IBAction func stopShairportSyncClicked(_ sender: NSMenuItem) {
		self.stopItem!.isEnabled = false
		self.shairportSyncAgent!.stop()
	}
	
}
