//
//  MessegesViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 23.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class MessegesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CommunicatorDelegate{
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var inputMessageTextView: UITextView!
    @IBOutlet var sendMessageButton: UIButton!
    
	var navigationItemTitle : String?
	var conversation : Conversation!
	let storageManager = StorageManager()
	
	var multipeerCommunicator : MultipeerCommunicator!
	
	fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
	
		let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
//		fetchRequest.predicate = NSPredicate.init(format: "conversation.conversationId == %@", conversation.conversationId!)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: storageManager.mainContext!, sectionNameKeyPath:nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		return fetchedResultsController
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		do {
			try fetchedResultsController.performFetch()
		} catch  {
			
		}
		
        self.navigationItem.title = conversation.name
        
		self.hideKeyboardWhenTappedAround()
		
		let backgroundImage = UIImage(named: "whatsapp.jpg")
		let imageView = UIImageView(image: backgroundImage)
		imageView.contentMode = .scaleAspectFill
		self.tableView.backgroundView = imageView
		
		multipeerCommunicator?.delegate = self
		
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
		guard let sections = fetchedResultsController.sections else { return 0 }
		return sections[section].numberOfObjects
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let modelFromDB = fetchedResultsController.object(at: indexPath)
		
		let cellIdentifier = modelFromDB.incomming ? "incomingCell" : "outgoingCell"
		
		let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageTableViewCell
		
		cell.textMessageLabel?.text = modelFromDB.text
		cell.isIncomming = modelFromDB.incomming
		
		return cell
	}
	
	//MARK: CoreData
	
	//MARK: CoreData methods
	func getConversationOnId(id: String) -> NSArray {
		
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
		request.predicate = NSPredicate.init(format: "conversationId == %@", id)
		
		var foundedObject: AnyObject? = nil
		
		do {
			
			foundedObject = try storageManager.saveContext!.fetch(request) as NSArray
		}
		catch let error as NSError {
			
			print("Ошибка при поиске в БД", error)
		}
		
		return foundedObject as! NSArray
	}
	
	
	//MARK: UITextViewDelegate
	
	func textViewDidBeginEditing(_ textView: UITextView)
	{
		textView.text = ""
		textView.becomeFirstResponder()
	}
	
//	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//		if(text == "\n") {
//			textView.resignFirstResponder()
//			return false
//		}
//		return true
//	}
	
	func textViewDidChange(_ textView: UITextView) {
		
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		
		let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: storageManager.saveContext!)
		message.setValue(textView.text, forKey: "text")
		message.setValue(false, forKey: "incomming")
		message.setValue(Date.init(timeIntervalSinceNow:0), forKey: "date")
		
		storageManager.performSave(context: storageManager.saveContext!) { }

		textView.resignFirstResponder()
	}

	@IBAction func sendMessage(_ sender: Any) {
	
		multipeerCommunicator.sendMessage(string: inputMessageTextView.text, to:conversation.conversationId!) { (Bool, Error) in
		}
		inputMessageTextView.text = ""
	}
	
	//discovering
	func didFoundUser(userID: MCPeerID, userName: String?) {
		NSLog("didFoundUser %@", userID.displayName)
	}
	
	func didLostUser(userID: String) {
		NSLog("didLostUser %@", userID)
        sendMessageButton.isEnabled = false
//		user.online = false
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
        
		let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: storageManager.saveContext!)
		message.setValue(text, forKey: "text")
		message.setValue(true, forKey: "incomming")
		message.setValue(Date.init(timeIntervalSinceNow:0), forKey: "date")
		
		storageManager.performSave(context: storageManager.saveContext!) { }
		
//        OperationQueue.main.addOperation {
//            self.tableView.reloadData()
//            self.tableView.updateConstraints()
//        }
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


// MARK: - NSFetchedResultsControllerDelegate

extension MessegesViewController : NSFetchedResultsControllerDelegate {
	
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
