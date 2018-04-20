//
//  ConversationsListViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData


class ConversationsListViewController: UITableViewController, ThemesViewControllerDelegate, CommunicatorDelegate {

	var isFirstStart = false
	var themesVC : ThemesViewController = ThemesViewController()
	let multipeerCommunicator = MultipeerCommunicator()
	
	var dictionaryUsers = [String : ConversationModel]()
	var arrayUsers = [ConversationModel]()
	
	var storageManager = StorageManager()
	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
	
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
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let sections = fetchedResultsController?.sections else { return 0 }
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = fetchedResultsController.sections else { return 0 }
		return sections[section].numberOfObjects
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let identifier = "ConversationCell"
		
		let modelFromDB = fetchedResultsController?.object(at: indexPath) as! ConversationModel
		
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ConversationTableViewCell
		
		cell.configureCell(modelFromDB)
		
		return cell
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if  segue.identifier == "ConversationSegueIdentifier" {
			let destination = segue.destination as? MessegesViewController

			destination?.multipeerCommunicator = multipeerCommunicator
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
		arrayUsers.sort {$0.name! < $1.name!}
		
		OperationQueue.main.addOperation {
			self.tableView.reloadData()
			self.tableView.updateConstraints()
		}
	}
	
	
	//MARK: CommunicatorDelegate
	
	//discovering
	func didFoundUser(userID: MCPeerID, userName: String?) {
		NSLog("didFoundUser %@", userID)
		
		let conversation = NSManagedObject.createEntityInContext("Conversation")
		conversation.setValue(userID.displayName, forKey: "conversationId")
		conversation.setValue(userName, forKey: "name")
		conversation.setValue(true, forKey: "online")
		
		conversation.insertByID(userID.displayName)
		
		let context = StorageManager.sharedStorageManager.saveContext
		
		StorageManager.sharedStorageManager.performSave(context: context!) { }
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
	
	
	//MARK: CoreData methods
	
	func initializeFetchedResultsController() {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
//		let datelastMessageSort = NSSortDescriptor(key: "department.name", ascending: true)
//		let lastNameSort = NSSortDescriptor(key: "lastName", ascending: true)
//		request.sortDescriptors = [departmentSort, lastNameSort]
		
		let context = storageManager.mainContext! as NSManagedObjectContext
		fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("Failed to initialize FetchedResultsController: \(error)")
		}
	}
}


// MARK: - NSFetchedResultsControllerDelegate

extension ConversationsListViewController : NSFetchedResultsControllerDelegate {

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
		case .delete:
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
		case .move:
			break
		case .update:
			break
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .fade)
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .fade)
		case .update:
			tableView.reloadRows(at: [indexPath!], with: .fade)
		case .move:
			tableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}



