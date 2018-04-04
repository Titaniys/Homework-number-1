//
//  MessageModel.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 01.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class MessageModel: NSObject {

	var textMessage : String
	var isIncomming : Bool

	init(textMessage: String, isIncomming : Bool) {
		self.textMessage = textMessage
		self.isIncomming = isIncomming
	}
}
