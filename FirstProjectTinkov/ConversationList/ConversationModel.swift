//
//  ConversationModel.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 04.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration : class {
	var name : String? {get set}
	var message : String? {get set}
	var date : Date? {get set}
	var online : Bool {get set}
	var hasUnrealMessage : Bool {get set}
	
}

class ConversationModel: NSObject, ConversationCellConfiguration {
	
	var name: String?
	var message: String?
	var date: Date?
	var online: Bool = false
	var hasUnrealMessage: Bool = false

}
