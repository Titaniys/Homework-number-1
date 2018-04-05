//
//  ConversationTableViewCell.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 23.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	
	func configureCell(_ model: ConversationModel) {
		nameLabel.text = model.name?.displayName
        let lastObject = model.arrayMessages.last
        if (lastObject != nil) {
            messageLabel.text = lastObject?.textMessage
        }
		messageLabel.text = "Пока нет сообщений..."
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "hh:mm:ss"
		dateLabel.text = dateFormatter.string(from:model.date!)
	}
	
	
}


