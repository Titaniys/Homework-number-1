//
//  CommunicatorManager.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 04.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class CommunicatorManager: NSObject, CommunicatorDelegate {
	
	var delegateList = [CallbackProtocol]()
	
	//discovering
	func didFoundUser(userID: String, userName: String?) {
		NSLog("didFoundUser %@", userID)
	}
	
	func didLostUser(userID: String) {
		NSLog("didLostUser %@", userID)
	}
	
	//errors
	func failedToStartBrowsingForUser(error: Error) {
		NSLog("failedToStartBrowsingForUser")
	}
	
	func failedToStartAdvertising(error: Error) {
		NSLog("failedToStartBrowsingForUser")
	}
	
	//messages
	func didReceiveMessage(text: String, fromUser: String, toUser: String) {
		NSLog("didReceiveMessage %@ fromUser %@ toUser %@", text, fromUser, toUser)
	}

}
