//
//  ConversationModel.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 04.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData


protocol ConversationCellConfiguration : class {
	
	var name : String? {get set}
	var conversationId : String? {get set}
	var lastMessage : String? {get set}
	var date : Date? {get set}
	var online : Bool {get set}
	var hasUnrealMessage : Bool {get set}
    var arrayMessages : [MessageModel] {get set}
	
}


class ConversationModel: NSObject, ConversationCellConfiguration, NSFetchRequestResult {
	
	var name: String?
	var conversationId: String?
	var lastMessage: String?
	var date: Date?
	var online: Bool = false
	var hasUnrealMessage: Bool = false
    
    var arrayMessages = [MessageModel]()
	
}
