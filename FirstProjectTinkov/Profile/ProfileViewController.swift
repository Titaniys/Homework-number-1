//
//  ProfileViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 21.02.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController {

	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var nameTextField: UITextField!
	@IBOutlet var descriptTextView: UITextView!
	@IBOutlet weak var fotoButton: UIButton!
	
	@IBOutlet var buttonGCD: UIButton!
	@IBOutlet var buttonOperation: UIButton!
	@IBOutlet weak var profileImage: UIImageView!
	
	let readerWriterGCD = GCDDataManager()
	var readerWriterOperation = OperationDataManager()
	
	var oldModel : DataModelOfUser?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		nameTextField.delegate = self
		descriptTextView.delegate = self

		setupUI()
		
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
		
		buttonGCD.tag = 1
		buttonGCD.layer.cornerRadius = 10
		buttonGCD.layer.borderWidth = 2
		buttonGCD.layer.borderColor = UIColor.black.cgColor
		buttonGCD.isEnabled = false
		
		buttonOperation.tag = 2
		buttonOperation.layer.cornerRadius = 10
		buttonOperation.layer.borderWidth = 2
		buttonOperation.layer.borderColor = UIColor.black.cgColor
		buttonOperation.isEnabled = false
		
		profileImage.clipsToBounds = true
		profileImage.layer.cornerRadius = 15
		
		nameTextField.isEnabled = false
		descriptTextView.isEditable = false
		
		// Чтение с помощью Operation
		readerWriterOperation.isReading = true
		readerWriterOperation.completionBlock = {
			OperationQueue.main.addOperation {
				self.nameTextField.text = self.readerWriterOperation.outputModel?.textName
				self.descriptTextView.text = self.readerWriterOperation.outputModel?.textDescript
				self.profileImage.image = self.readerWriterOperation.outputModel?.imagePhoto
				self.oldModel = self.readerWriterOperation.outputModel
			}
		}
		
		let readQueue = OperationQueue()
		readQueue.addOperation(readerWriterOperation)
		readQueue.waitUntilAllOperationsAreFinished()


		// Чтение с помощью GCD
		let queue = DispatchQueue.global(qos: .utility)
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
		queue.async {
			let outputModel : DataModelOfUser = self.readerWriterGCD.readFiles()
				DispatchQueue.main.async {
					self.profileImage.image = outputModel.imagePhoto
					self.nameTextField.text = outputModel.textName
					self.descriptTextView.text = outputModel.textDescript
					self.oldModel = outputModel
					self.activityIndicator.isHidden = true
					self.activityIndicator.stopAnimating()
				}
			}

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
		
		switch sender.tag {
		case 1:
			activityIndicator.isHidden = false
			activityIndicator.startAnimating()
			
			fotoButton.isEnabled = false
			buttonGCD.isEnabled = false
			buttonOperation.isEnabled = false
			nameTextField.isEnabled = false
			descriptTextView.isEditable = false
			
			let inputModel = DataModelOfUser()
			inputModel.imagePhoto = profileImage.image
			inputModel.textName = nameTextField.text
			inputModel.textDescript = descriptTextView.text
			
			let queue = DispatchQueue.global(qos: .utility)
			queue.async {
				self.readerWriterGCD.writeFiles(inputModel)
				DispatchQueue.main.async {
					self.activityIndicator.stopAnimating()
					self.buttonGCD.isEnabled = true
					self.buttonOperation.isEnabled = true
					
					let alert = UIAlertController(title: "Данные сохранены!", message: "", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { action in
					}))
					self.present(alert, animated: true, completion: nil)
					
					}
				}
			
			break
		case 2:
			// Запись с помощью Operation
			
			activityIndicator.isHidden = false
			activityIndicator.startAnimating()
			
			fotoButton.isEnabled = false
			buttonGCD.isEnabled = false
			buttonOperation.isEnabled = false
			nameTextField.isEnabled = false
			descriptTextView.isEditable = false
			
			let inputModel = DataModelOfUser()
			inputModel.imagePhoto = profileImage.image
			inputModel.textName = nameTextField.text
			inputModel.textDescript = descriptTextView.text
			
			readerWriterOperation = OperationDataManager()
			readerWriterOperation.isReading = false
			readerWriterOperation.inputModel = inputModel
			readerWriterOperation.outputModel = oldModel
			
			readerWriterOperation.completionBlock = {
				OperationQueue.main.addOperation {
					self.activityIndicator.stopAnimating()
					self.buttonGCD.isEnabled = true
					self.buttonOperation.isEnabled = true

					let alert = UIAlertController(title: "Данные сохранены!", message: "", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { action in
					}))
					self.present(alert, animated: true, completion: nil)
				}
			}
			
			let writeQueue = OperationQueue()
			writeQueue.addOperation(readerWriterOperation)
		
			break
		default:
			break
		}
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
	
}

	
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	//MARK: UIImagePickerControllerDelegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let imageFromPC = info[UIImagePickerControllerOriginalImage] as! UIImage
		profileImage.image = imageFromPC

		if oldModel?.imagePhoto != imageFromPC {
			buttonOperation.isEnabled = true
			buttonGCD.isEnabled = true
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
			buttonOperation.isEnabled = true
			buttonGCD.isEnabled = true
		}
	}
	
	func textViewDidBeginEditing(_ textView: UITextView)
	{
		textView.becomeFirstResponder()
	}
	
	func textViewDidEndEditing(_ textView: UITextView)
	{
		if oldModel?.textDescript != textView.text {
			buttonOperation.isEnabled = true
			buttonGCD.isEnabled = true
		}
		textView.resignFirstResponder()
	}
}
