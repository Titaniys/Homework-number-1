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
		
		let offset = self.frame.width / 4
		
		textMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		textMessageLabel.numberOfLines = 0
		textMessageLabel.sizeToFit()
		textMessageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		if isIncomming {
			
			let leadingConstraint = NSLayoutConstraint(item: textMessageLabel,
													   attribute: NSLayoutAttribute.leading,
													   relatedBy: NSLayoutRelation.equal,
													   toItem: self,
													   attribute: NSLayoutAttribute.leading,
													   multiplier: 1,
													   constant: 15)
			
			let trailingConstraint = NSLayoutConstraint(item: textMessageLabel,
														  attribute: NSLayoutAttribute.trailing,
														  relatedBy: NSLayoutRelation.equal,
														  toItem: self,
														  attribute: NSLayoutAttribute.trailing,
														  multiplier: 1,
														  constant: -offset)
			trailingConstraint.priority = UILayoutPriority(rawValue: 1000)
			trailingConstraint.isActive = true
			
			NSLayoutConstraint.activate([leadingConstraint, trailingConstraint])
			
			//textMessageLabel?.frame = CGRect(x: 0, y: 0, width: self.frame.width - offset, height: 50)
			textMessageLabel.backgroundColor = UIColor.blue
		}
		else {
			//textMessageLabel?.frame = CGRect(x: offset, y: 0, width: self.frame.width - offset, height: 50)
			textMessageLabel.backgroundColor = UIColor.yellow
			
//			let leadingConstraint = NSLayoutConstraint(item: textMessageLabel,
//														attribute: NSLayoutAttribute.leading,
//														relatedBy: NSLayoutRelation.greaterThanOrEqual,
//														toItem: self,
//														attribute: NSLayoutAttribute.leading,
//														multiplier: 1,
//														constant: offset)
//			leadingConstraint.priority = UILayoutPriority(rawValue: 250)
//
//			let trailingConstraint = NSLayoutConstraint(item: textMessageLabel,
//														attribute: NSLayoutAttribute.trailing,
//														relatedBy: NSLayoutRelation.equal,
//														toItem: self,
//														attribute: NSLayoutAttribute.trailing,
//														multiplier: 1,
//														constant: -15)
//
//			NSLayoutConstraint.activate([leadingConstraint, trailingConstraint])
		}
	}
	
}
