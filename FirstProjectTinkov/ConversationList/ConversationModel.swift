//
//  ConversationModel.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 04.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ConversationCellConfiguration : class {
	var name : MCPeerID? {get set}
	var lastMessage : String? {get set}
	var date : Date? {get set}
	var online : Bool {get set}
	var hasUnrealMessage : Bool {get set}
    var arrayMessages : [MessageModel] {get set}
	
}


class ConversationModel: NSObject, ConversationCellConfiguration {
	
	var name: MCPeerID?
	var lastMessage: String?
	var date: Date?
	var online: Bool = false
	var hasUnrealMessage: Bool = false
    
    var arrayMessages = [MessageModel]()
    

}
