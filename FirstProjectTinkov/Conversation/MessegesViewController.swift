//
//  MessegesViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 23.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class MessegesViewController: UIViewController, UITableViewDataSource {


	var arrayMessages = [MessageModel]()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let firstModel : MessageModel = MessageModel(textMessage: "Incomming sdfsdf  sdf sdf sdf sdfxc xcv sdfdsfsdf sd sdfsdfd sdf sd", isIncomming: true)
		let firstModel1 : MessageModel = MessageModel(textMessage: "Incomming", isIncomming: true)
		
		let secondModel : MessageModel = MessageModel(textMessage: "textMess ageLabel textMe ssageLabel textMessageLabel textMessageLabel textMessageLabel textMessageLabel textMessageLabel", isIncomming: false)
		let threeModel : MessageModel = MessageModel(textMessage: "textMessage", isIncomming: false)
		
		arrayMessages = [firstModel, secondModel, threeModel, firstModel1]
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(ProfileViewController.keyboardWillShow),
											   name: NSNotification.Name.UIKeyboardWillShow,
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(ProfileViewController.keyboardWillHide),
											   name: NSNotification.Name.UIKeyboardWillHide,
											   object: nil)
		
	}
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
		super.viewWillDisappear(animated)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0{
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y != 0{
				self.view.frame.origin.y += keyboardSize.height
			}
		}
	}

	//MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayMessages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellIdentifier = "cellMessage"
		
		let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageTableViewCell
		
		cell.textMessageLabel?.text = arrayMessages[indexPath.row].textMessage
		cell.isIncomming = arrayMessages[indexPath.row].isIncomming
		
		return cell
	}
	

}
