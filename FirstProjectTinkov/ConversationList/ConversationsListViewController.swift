//
//  ConversationsListViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ConversationsListViewController: UITableViewController, ThemesViewControllerDelegate, CommunicatorDelegate {

	var isFirstStart = false
	var themesVC : ThemesViewController = ThemesViewController()
	let multipeerCommunicator = MultipeerCommunicator()
	
	var dictionaryUsers = [String : ConversationModel]()
	var arrayUsers = [ConversationModel]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	

	override func viewWillAppear(_ animated: Bool) {
        multipeerCommunicator.delegate = self
        reloadData()
	}
	
    
	//MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70;
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Online"
		} else {
			return "Offline"
		}
	}
	
	
	//MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayUsers.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let identifier = "ConversationCell"
		
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ConversationTableViewCell
		
		cell.configureCell(arrayUsers[indexPath.row])
		
		return cell
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if  segue.identifier == "ConversationSegueIdentifier" {
			let destination = segue.destination as? MessegesViewController

			destination?.multipeerCommunicator = multipeerCommunicator
			destination?.dictionaryUsers = dictionaryUsers
			let selectedItem : Int = (tableView.indexPathForSelectedRow?.row)!
			destination?.user = arrayUsers[selectedItem]
		}
	}
	
	

	@IBAction func didTap(_ sender: Any) {
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "ThemesViewController")
		self.themesVC = vc as! ThemesViewController
		self.themesVC.delegate = self
		self.present(vc!, animated: true, completion: nil)
	}

	
	//MARK: ThemesViewControllerDelegate
	
	func themesViewController(_ controller: ThemesViewController!, didSelectTheme selectedTheme: UIColor!) {
		logThemeChanging(selectedTheme: selectedTheme)
	}

	func logThemeChanging(selectedTheme: UIColor) {
		print(selectedTheme)
	}
	
	func reloadData()  {
		
		arrayUsers.removeAll()
		for model in dictionaryUsers.values {
			if model.online {
				arrayUsers.append(model)
			}
		}
		
		OperationQueue.main.addOperation {
			self.tableView.reloadData()
			self.tableView.updateConstraints()
		}
	}
	
	
	//MARK: CommunicatorDelegate
	
	//discovering
	func didFoundUser(userID: MCPeerID, userName: String?) {
		NSLog("didFoundUser %@", userID)
		
		let invitedUser : ConversationModel = ConversationModel()
		invitedUser.name = userName
		invitedUser.peer = userID
		invitedUser.online = true
		dictionaryUsers[userID.displayName] = invitedUser
		
		reloadData()
	}
	
	func didLostUser(userID: String) {
		NSLog("didLostUser %@", userID)
		dictionaryUsers[userID] = nil
		
		reloadData()
		
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
		
		let inputText: MessageModel = MessageModel(textMessage: text, isIncomming: true)
		dictionaryUsers[fromUser]?.arrayMessages.append(inputText)
		dictionaryUsers[fromUser]?.date = Date.init(timeIntervalSinceNow:0)
		
		reloadData()
	}
	
}



