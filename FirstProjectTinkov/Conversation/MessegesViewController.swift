//
//  MessegesViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 23.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class MessegesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CommunicatorDelegate{
	
	@IBOutlet var tableView: UITableView!

	@IBOutlet var inputMessageTextView: UITextView!
	
	var arrayMessages = [MessageModel]()
	var navigationItemTitle : String?
	var userID : String?
	
	var multipeerCommunicator : MultipeerCommunicator!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.title = navigationItemTitle
		self.hideKeyboardWhenTappedAround()
		
		let backgroundImage = UIImage(named: "whatsapp.jpg")
		let imageView = UIImageView(image: backgroundImage)
		imageView.contentMode = .scaleAspectFill
		self.tableView.backgroundView = imageView
		
		multipeerCommunicator?.delegate = self
		
		let threeModel : MessageModel = MessageModel(textMessage: "textMessage", isIncomming: false)
		
		arrayMessages = [threeModel]
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(MessegesViewController.keyboardWillShow),
											   name: NSNotification.Name.UIKeyboardWillShow,
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(MessegesViewController.keyboardWillHide),
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
	
	//MARK: UITableViewDelegate
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = .clear
		
	}
	
	//MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayMessages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellIdentifier = arrayMessages[indexPath.row].isIncomming ? "incomingCell" : "outgoingCell"
		
		let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageTableViewCell
		
		cell.textMessageLabel?.text = arrayMessages[indexPath.row].textMessage
		cell.isIncomming = arrayMessages[indexPath.row].isIncomming
		
		return cell
	}
	
	
	
	//MARK: UITextViewDelegate
	
	func textViewDidBeginEditing(_ textView: UITextView)
	{
		textView.text = ""
		textView.becomeFirstResponder()
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
		
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		let inputText: MessageModel = MessageModel(textMessage: textView.text!, isIncomming: false)
		arrayMessages.append(inputText)
		tableView.reloadData()
		tableView.updateConstraints()
		
		multipeerCommunicator.sendMessage(string: textView.text, to: "Vadim") { (Bool, Error) in
			
		}
		inputMessageTextView.text = ""
		
	}

	//MARK: CallbackProtocol
	
	//discovering
	func didFoundUser(userID: String, userName: String?) {
		NSLog("didFoundUser %@", userID)
	}
	
	func didLostUser(userID: String) {
		NSLog("didLostUser %@", userID)
	}
	
	//errors
	func failedToStartBrowsingForUser(error: Error) {
		NSLog("failedToStartBrowsingForUser")
	}
	
	func failedToStartAdvertising(error: Error) {
		NSLog("failedToStartBrowsingForUser")
	}
	
	//messages
	func didReceiveMessage(text: String, fromUser: String, toUser: String) {
		NSLog("didReceiveMessage %@ fromUser %@ toUser %@", text, fromUser, toUser)
	}
}

extension MessegesViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessegesViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
