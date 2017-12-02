//
//  Agent.swift
//  Shairport Sync Agent
//
//  Created by Tobias Strobel on 27.11.17.
//  Copyright © 2017 Tobias Strobel. All rights reserved.
//

import Foundation

class Agent {
	
	let url: URL
	
	private var process: Process?
	
	private var startCallbacks: [() -> Void] = []
	
	private var terminationCallbacks: [(Int32) -> Void] = []
	
	private var standardOutputCallbacks: [(Data) -> Void] = []
	
	private var standardErrorCallbacks: [(Data) -> Void] = []
	
	private var startErrorCallbacks: [(Error) -> Void] = []
	
	init(_ url: URL) {
		self.url = url
	}
	
	func start(_ arguments: [String]? = nil) {
		if (self.process == nil) {
			self.process = Process()
			self.process!.executableURL = url
			if let arguments = arguments {
				self.process!.arguments = arguments
			}
			self.addTerminationObserver()
			self.addStandardOutputObserver()
			self.addStandardErrorObserver()
			do {
				try self.process!.run()
				for callback in self.startCallbacks {
					callback()
				}
			} catch {
				print("error")
				self.process = nil
				for callback in self.startErrorCallbacks {
					callback(error)
				}
			}
		}
	}
	
	func stop() {
		if let process = self.process {
			process.terminate()
		}
	}

	func addStartCallback(_ callback: @escaping () -> Void) {
		self.startCallbacks.append(callback)
	}
	
	func addTerminationCallback(
		_ callback: @escaping (Int32) -> Void
	) {
		self.terminationCallbacks.append(callback)
	}
	
	func addStandardOutputCallback(_ callback: @escaping (Data) -> Void) {
		self.standardOutputCallbacks.append(callback)
	}
	
	func addStandardErrorCallback(_ callback: @escaping (Data) -> Void) {
		self.standardErrorCallbacks.append(callback)
	}
	
	func addStartErrorCallback(_ callback: @escaping (Error) -> Void) {
		self.startErrorCallbacks.append(callback)
	}
	
	private func addTerminationObserver() {
		var observerToken: NSObjectProtocol!
		observerToken = NotificationCenter.default.addObserver(
			forName: Process.didTerminateNotification,
			object: self.process!,
			queue: nil
		) { notification -> Void in
			NotificationCenter.default.removeObserver(observerToken)
			for callback in self.terminationCallbacks {
				callback(self.process!.terminationStatus)
			}
			self.process = nil
		}
	}
	
	private func addStandardOutputObserver() {
		let pipe = Pipe()
		self.process!.standardOutput = pipe
		self.addPipeReader(pipe, self.standardOutputCallbacks)
	}
	
	private func addStandardErrorObserver() {
		let pipe = Pipe()
		self.process!.standardError = pipe
		self.addPipeReader(pipe, self.standardErrorCallbacks)
	}
	
	private func addPipeReader(_ pipe: Pipe, _ callbacks: [(Data) -> Void]) {
		let handle = pipe.fileHandleForReading
		handle.waitForDataInBackgroundAndNotify()
		var observerToken: NSObjectProtocol!
		observerToken = NotificationCenter.default.addObserver(
			forName: NSNotification.Name.NSFileHandleDataAvailable,
			object: handle,
			queue: nil
		) { notification -> Void in
			let data = handle.availableData
			if data.count > 0 {
				handle.waitForDataInBackgroundAndNotify()
				for callback in callbacks {
					callback(data)
				}
			} else {
				NotificationCenter.default.removeObserver(observerToken)
			}
		}
	}
	
}
