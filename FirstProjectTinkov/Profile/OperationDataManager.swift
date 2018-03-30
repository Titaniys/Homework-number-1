//
//  OperationDataManager.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 30.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class OperationDataManager: AsyncOperation {

	//File system
	let fileForPhoto = "fileForPhoto"
	let fileForName = "fileForName.txt"
	let fileForDescript = "fileForDescript.txt"
	
	var outputModel : DataModelOfUser?
	var inputModel : DataModelOfUser?
	
	var isReading : Bool?
	
	override func main() {

		if isReading == true {
			asyncReading() { [unowned self]  model in
				var tempModel = DataModelOfUser()
				tempModel = model!
				self.outputModel = tempModel
			}
			self.state = .finished
		} else {
			asyncWriting()
		}
		self.state = .finished
		
	}
	
	func asyncReading(completion:@escaping ((DataModelOfUser?) -> () )) {
		let tempModel = DataModelOfUser()
		tempModel.textDescript = (readFile(file: fileForDescript) as? String)!
		tempModel.textName = (readFile(file: fileForName) as? String)!
		tempModel.imagePhoto = UIImage.init(data: (readFile(file: fileForPhoto) as? Data)!)!
		
		completion(tempModel as DataModelOfUser)
	}
	
	func asyncWriting() {
		
		if outputModel?.textName != inputModel?.textName {
			writeFile(inputModel?.textName, toFile: fileForName)
		}
		if outputModel?.textDescript != inputModel?.textDescript {
			writeFile(inputModel?.textDescript, toFile: fileForDescript)
		}
		if outputModel?.imagePhoto != inputModel?.imagePhoto {
			writeFile(inputModel?.imagePhoto, toFile: fileForPhoto)
		}
	}
	
	//MARK: File system
	
	func writeFile(_ inputData: Any?, toFile: String) {
		
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			
			let fileURL = dir.appendingPathComponent(toFile)
			
			if toFile == fileForPhoto {
				if let data = UIImagePNGRepresentation((inputData as? UIImage)!) {
					try? data.write(to: fileURL)
				}
			}
			//writing
			do {
				let inputText = inputData as? String
				try inputText?.write(to: fileURL, atomically: false, encoding: .utf8)
			}
			catch {/* error handling here */}
		}
	}
	//Читаем из файла
	func readFile(file: String) -> Any? {
		
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let fileURL = dir.appendingPathComponent(file)
			
			if file == fileForPhoto {
				if let imageData = NSData.init(contentsOf: fileURL) {
					return imageData
				}
				let path = Bundle.main.path(forResource: "placeholder", ofType: "png")
				let imageDefault = NSData.init(contentsOfFile: path!)
				return imageDefault
			}
			
			do {
				let text = try String(contentsOf: fileURL, encoding: .utf8)
				return text
			}
			catch {/* error handling here */}
		}
		return "Заполните данные"
	}
}
