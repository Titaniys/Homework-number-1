//
//  ConversationsListViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit


class ConversationsListViewController: UITableViewController, ThemesViewControllerDelegate {

	
	var themesVC : ThemesViewController = ThemesViewController()

	override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70;
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let identifier = "ConversationCell"
		
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ConversationTableViewCell

		
		cell.nameLabel?.text = "Vadim"
		cell.messageLabel?.text = "hi world"
		cell.dateLabel?.text = "12:12"
		
		return cell
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
}
