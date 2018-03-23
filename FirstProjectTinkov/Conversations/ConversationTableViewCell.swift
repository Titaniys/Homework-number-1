//
//  ConversationTableViewCell.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 23.03.18.
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

class ConversationTableViewCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var name: String?
	var message: String?
	var date: Date?
	var online = false
	var hasUnrealMessage = false
	
}


