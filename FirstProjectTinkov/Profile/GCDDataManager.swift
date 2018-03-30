//
//  GCDDataManager.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 28.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit

class GCDDataManager: NSObject {
	
	//File system
	let fileForPhoto = "fileForPhoto"
	let fileForName = "fileForName.txt"
	let fileForDescriptSelf = "fileForDescript.txt"
	
	var oldModel : DataModelOfUser?
	
	func writeFiles(_ inputModel : DataModelOfUser) {
		
		if oldModel?.textName != inputModel.textName {
			writeFile(inputModel.textName, toFile: fileForName)
		}
		if oldModel?.textDescript != inputModel.textDescript {
			writeFile(inputModel.textDescript, toFile: fileForDescriptSelf)
		}
		if oldModel?.imagePhoto != inputModel.imagePhoto {
			writeFile(inputModel.imagePhoto, toFile: fileForPhoto)
		}
	}
	
	func readFiles()  -> DataModelOfUser {
		
		let outputModel = DataModelOfUser()
		
		outputModel.textDescript = (readFile(file: fileForDescriptSelf) as? String)!
		outputModel.textName = (readFile(file: fileForName) as? String)!
		outputModel.imagePhoto = UIImage.init(data: (readFile(file: fileForPhoto) as? Data)!)!
		
		oldModel = outputModel
		return outputModel
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
