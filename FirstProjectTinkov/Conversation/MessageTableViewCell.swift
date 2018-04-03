//
//  MessageTableViewCell.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 01.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

protocol MessageTableViewCellConfiguration: class {
	var textMessage : String? {get set}
	var isIncomming : Bool! {get set}
}

class MessageTableViewCell: UITableViewCell, MessageTableViewCellConfiguration {
	
	
	@IBOutlet weak var textMessageLabel: UILabel!
	
	var isIncomming: Bool!

	var textMessage : String? {
		set {
			self.textMessage = newValue
		}
		get {
			return self.textMessage
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		createConstraint()
		textMessageLabel.layer.masksToBounds = true
		textMessageLabel.layer.cornerRadius = 10
		textMessageLabel.layer.backgroundColor = UIColor.green.cgColor
		
	}
	
	func createConstraint() {
		
		textMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		textMessageLabel.numberOfLines = 0
		textMessageLabel.sizeToFit()
		textMessageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let offset = self.frame.width / 4
		if isIncomming {
			
			let trailingConstraint = NSLayoutConstraint(item: textMessageLabel,
														attribute: NSLayoutAttribute.trailing,
														relatedBy: NSLayoutRelation.lessThanOrEqual,
														toItem: self,
														attribute: NSLayoutAttribute.trailing,
														multiplier: 1,
														constant: -offset)
			
			
			NSLayoutConstraint.activate([trailingConstraint])
			
			textMessageLabel.backgroundColor = UIColor.blue
		}
		else {
			textMessageLabel.backgroundColor = UIColor.yellow
			
			let leadingConstraint = NSLayoutConstraint(item: textMessageLabel,
													   attribute: NSLayoutAttribute.leading,
													   relatedBy: NSLayoutRelation.greaterThanOrEqual,
													   toItem: self,
													   attribute: NSLayoutAttribute.leading,
													   multiplier: 1,
													   constant: offset)
			NSLayoutConstraint.activate([leadingConstraint])
		}
	}
	
}
