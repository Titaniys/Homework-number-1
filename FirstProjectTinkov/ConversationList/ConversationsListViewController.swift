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
	
	let storageManager = StorageManager()
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Conversation> = {
        
        let fetchRequest : NSFetchRequest<Conversation> = Conversation.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: storageManager.mainContext!, sectionNameKeyPath: "name", cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            
        }

    }

	override func viewWillAppear(_ animated: Bool) {
        multipeerCommunicator.delegate = self
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
        guard let sections = fetchedResultsController.sections else { return 0 }
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = fetchedResultsController.sections else { return 0 }
		return sections[section].numberOfObjects
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let identifier = "ConversationCell"
		
		let modelFromDB = fetchedResultsController.object(at: indexPath)
		
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
	
	
	//MARK: CommunicatorDelegate
	
	//discovering
	func didFoundUser(userID: MCPeerID, userName: String?) {
		NSLog("didFoundUser %@", userID)
		
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        request.predicate = NSPredicate.init(format: "conversationId == %@", userID.displayName)
        
        var foundedObject: AnyObject? = nil
        
        do {
            
            foundedObject = try storageManager.saveContext!.fetch(request) as NSArray
        }
        catch let error as NSError {
            
            print("Ошибка при поиске в БД", error)
        }
        
        if ((foundedObject?.count) != 0) {
            foundedObject?.setValue(true, forKey: "online")
        }
        else {
            let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: storageManager.saveContext!)
            conversation.setValue(userID.displayName, forKey: "conversationId")
            conversation.setValue(userName, forKey: "name")
            conversation.setValue(true, forKey: "online")
        }
        storageManager.performSave(context: storageManager.saveContext!) { }
	}
	
	func didLostUser(userID: String) {
		NSLog("didLostUser %@", userID)
		dictionaryUsers[userID] = nil
		
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
	}
	
	
	//MARK: CoreData methods
	
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



