//
//  ConversationsListViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit


class ConversationsListViewController: UITableViewController, ThemesViewControllerDelegate, CommunicatorDelegate {
	

	var themesVC : ThemesViewController = ThemesViewController()
	let multipeerCommunicator = MultipeerCommunicator()
	var arrayUsers = [ConversationModel]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		multipeerCommunicator.delegate = self
		
		let one : ConversationModel = ConversationModel()
		one.name = "Vadim"
		one.message = "Some message Some message Some message"
		one.date = Date.init(timeIntervalSinceNow: 0)
		one.online = true
		
		let two : ConversationModel = ConversationModel()
		two.name = "NotVadim"
		two.message = "Some1 message Some message Some message111"
		two.date = Date.init(timeIntervalSinceNow: 10000)
		two.online = true
		
		arrayUsers.append(one)
		arrayUsers.append(two)
		
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
			
			let selectedItem : Int = (tableView.indexPathForSelectedRow?.row)!
			destination?.navigationItemTitle = arrayUsers[selectedItem].name
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
	
	
	//MARK: CommunicatorDelegate
	
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



