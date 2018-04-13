//
//  ProfileViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 21.02.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, NSFetchedResultsControllerDelegate {

	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var nameTextField: UITextField!
	@IBOutlet var descriptTextView: UITextView!
	@IBOutlet weak var fotoButton: UIButton!
	
	@IBOutlet var buttonEditProfile: UIButton!
	@IBOutlet weak var profileImage: UIImageView!
	
	let readerWriterGCD = GCDDataManager()
	var readerWriterOperation = OperationDataManager()
	
	var oldModel : UserModel?
	let storageManager = StorageManager()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		nameTextField.delegate = self
		descriptTextView.delegate = self

		setupUI()
		setupData()
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
	
	
	func setupUI() {
		
		fotoButton.layer.cornerRadius = 15
		fotoButton.isEnabled = false
		
		buttonEditProfile.tag = 2
		buttonEditProfile.layer.cornerRadius = 10
		buttonEditProfile.layer.borderWidth = 2
		buttonEditProfile.layer.borderColor = UIColor.black.cgColor
		buttonEditProfile.isEnabled = false
		
		profileImage.clipsToBounds = true
		profileImage.layer.cornerRadius = 15
		
		nameTextField.isEnabled = false
		descriptTextView.isEditable = false
		activityIndicator.stopAnimating()
		
	}
	
	func setupData() {
		
		let context = storageManager.mainContext! as NSManagedObjectContext
		let user : UserModel? = StorageManager.findOrInsertUserModel(in: context)
		
		nameTextField.text = user?.textName
		descriptTextView.text = user?.textDescript
		profileImage.image = user?.imagePhoto
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.first != nil {
			view.endEditing(true)
		}
		super.touchesBegan(touches, with: event)
	}
	
	
	//MARK: Actions
	
	@IBAction func exitButton(_ sender: Any) {
		dismiss(animated: true) {
		}
	}
	
	@IBAction func photoChanger(_ sender: Any) {
		
		let alert = UIAlertController(title: "Выбор аватара", message: "Выберите аватар из галереи или сделаете новый", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
			self.changeAvatar(isCamera: true)
			}))
		alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
			self.changeAvatar(isCamera: false)
		}))
		self.present(alert, animated: true, completion: nil)
		
	}
	
	@IBAction func safeAction(_ sender: UIButton) {
		saveData()
	}

	func saveData() {
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
		
		let context : NSManagedObjectContext = storageManager.saveContext!
		
		do {
			try context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "UserDataModel")))
		} catch { }
		storageManager.performSave(context: context, completionHandler: { })
		
		let user = UserModel.insertUserModel(in: context)
		
		let imageData : Data? = UIImagePNGRepresentation(profileImage.image!)
		user.setValue(nameTextField.text, forKey: "textName")
		user.setValue(descriptTextView.text, forKey: "textDescript")
		user.setValue(imageData, forKey: "imagePhoto")
		
		storageManager.performSave(context: context, completionHandler: {
			DispatchQueue.main.async {
				let alert = UIAlertController(title: "Данные сохранены!", message: "", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { action in
				}))
				self.present(alert, animated: true, completion: nil)
				self.activityIndicator.stopAnimating()
			}
		})
	}
	
	@IBAction func editAction(_ sender: Any) {
		fotoButton.isEnabled = true
		nameTextField.isEnabled = true
		descriptTextView.isEditable = true
	}
	
	
	//MARK:
	
	func changeAvatar(isCamera: Bool) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		
		if isCamera {
			imagePicker.sourceType = UIImagePickerControllerSourceType.camera
		}
		
		self.present(imagePicker, animated: true, completion:nil)
	}
	
	//MARK: CoreData
	
}

	
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	//MARK: UIImagePickerControllerDelegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let imageFromPC = info[UIImagePickerControllerOriginalImage] as! UIImage
		profileImage.image = imageFromPC

		if oldModel?.imagePhoto != imageFromPC {
			buttonEditProfile.isEnabled = true
		}
		
		self.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension ProfileViewController: UITextFieldDelegate, UITextViewDelegate {
	
	
	//MARK: UITextFieldDelegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		nameTextField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if oldModel?.textName != textField.text {
			buttonEditProfile.isEnabled = true
		}
	}
	
	func textViewDidBeginEditing(_ textView: UITextView)
	{
		textView.becomeFirstResponder()
	}
	
	func textViewDidEndEditing(_ textView: UITextView)
	{
		if oldModel?.textDescript != textView.text {
			buttonEditProfile.isEnabled = true
		}
		textView.resignFirstResponder()
	}
}
