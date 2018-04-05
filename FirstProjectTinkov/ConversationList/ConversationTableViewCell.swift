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
		nameLabel.text = model.name
        let lastObject = model.arrayMessages.last
        if (lastObject != nil) {
            messageLabel.text = lastObject?.textMessage
		} else {
			messageLabel.text = "Пока нет сообщений..."
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		if (model.date != nil)  {
			dateLabel.text = dateFormatter.string(from:model.date!)
		} else {
			dateLabel.text = ""
		}
		
	}
	
	
}


