//
//  ViewController.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 21.02.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.functionNameLifeCycleOfViewController(#function)
		
		view.backgroundColor = .white
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.functionNameLifeCycleOfViewController(#function)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.functionNameLifeCycleOfViewController(#function)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		self.functionNameLifeCycleOfViewController(#function)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.functionNameLifeCycleOfViewController(#function)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.functionNameLifeCycleOfViewController(#function)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.functionNameLifeCycleOfViewController(#function)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	func functionNameLifeCycleOfViewController(_ funcName: String) {
		NSLog("Name of the view controller's life cycle function %@", funcName)
	}
}

