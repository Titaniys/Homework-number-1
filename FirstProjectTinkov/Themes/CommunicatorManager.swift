//
//  CommunicatorManager.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 04.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class CommunicatorManager: NSObject, CommunicatorDelegate {
	
	func didFoundUser(userID: String, userName: String?) {
		
	}
	
	func didLostUser(userID: String) {
		
	}
	
	func failedToStartBrowsingForUser(error: Error) {
		
	}
	
	func failedToStartAdvertising(error: Error) {
		
	}
	
	func didReceiveMessage(text: String, fromUser: String, toUser: String) {
		
	}
}
