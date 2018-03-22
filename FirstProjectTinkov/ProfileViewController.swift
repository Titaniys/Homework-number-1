//
//  ProfileViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 21.02.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var companyLabel: UILabel!
	@IBOutlet weak var fotoButton: UIButton!
	@IBOutlet weak var editButton: UIButton!
	@IBOutlet weak var profileImage: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		setupUI()
		
	}
	
	func setupUI() {
		fotoButton.layer.cornerRadius = 30
		
		editButton.layer.cornerRadius = 30
		editButton.layer.borderWidth = 2
		editButton.layer.borderColor = UIColor.black.cgColor
		
		profileImage.layer.cornerRadius = 30
		let image : UIImage = UIImage(named: "personIcon")!
		profileImage = UIImageView(image:image)
	}
	
	@IBAction func editAction(_ sender: Any) {
		//let button = sender as? UIButton
		
		print("Выберите изображение профиля")
	}
}

