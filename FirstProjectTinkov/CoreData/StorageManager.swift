//
//  StorageManager.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 12.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import CoreData


class StorageManager: NSObject {

	
	static let sharedStorageManager = StorageManager()
	
	private var storageURL : URL {
		let documentDirUrl : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let url = documentDirUrl.appendingPathComponent("profileStore")
		return url
	}
	
	
	private let managedObjectModelName = "MessagerModels"
	private var _managedObjectModel : NSManagedObjectModel?
	private var managedObjectModel : NSManagedObjectModel? {
		get {
			if _managedObjectModel == nil {
				guard let modelURL = Bundle.main.url(forResource: managedObjectModelName, withExtension: "momd")
					else {
						print ("Empty model url!")
						return nil
				}
				_managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
			}
			return _managedObjectModel
		}
	}
	
	private var _persistentStoreCoordinator : NSPersistentStoreCoordinator?
	private var persistentStoreCoordinator : NSPersistentStoreCoordinator? {
		get {
			if _persistentStoreCoordinator == nil {
				guard let model = self.managedObjectModel else {
					print("Empty managed object model!")
					return nil
				}
				_persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
				
				do {
					try _persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
																		configurationName:nil,
																		at: storageURL,
																		options:nil)
				} catch {
					assert(false, "Error adding persistent store to coordinator: \(error)")
				}
			}
			return _persistentStoreCoordinator
		}
	}

	/// Контекст для сохранения в CoreData
	private var _masterContext : NSManagedObjectContext?
	private var  masterContext : NSManagedObjectContext? {
		get {
			if _masterContext == nil {
				let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
				guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
					print("Empty persistent store coordinator")
					return nil
				}
				context.persistentStoreCoordinator = persistentStoreCoordinator
				context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
				context.undoManager = nil
				_masterContext = context
			}
			return _masterContext
		}
	}
	
	
	/// Контекст для отображения данных на UI
	private var _mainContext : NSManagedObjectContext?
	public var mainContext : NSManagedObjectContext? {
		get {
			if _mainContext == nil {
				let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
				guard let parentContext = self.masterContext else {
					print("No master context")
					return nil
				}
				context.parent = parentContext
				context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
				context.undoManager = nil
				_mainContext = context
			}
			return _mainContext
		}
	}
	
	
	/// Верхнеуровневый контекст
	private var _saveContext : NSManagedObjectContext?
	public var saveContext : NSManagedObjectContext? {
		get {
			if _saveContext == nil {
				let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
				guard let parentContext = self.mainContext else {
					print("No master context")
					return nil
				}
				context.parent = parentContext
				context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
				context.undoManager = nil
				_saveContext = context
			}
			return _saveContext
		}
	}
	
	
	/// Рекурсивное сохранение контекстов
	///
	/// - Parameters:
	///   - context: контекст
	///   - completionHandler: блок вызываемый по завершению
	public func performSave(context: NSManagedObjectContext, completionHandler : (() -> Void)? ) {
		
		if context.hasChanges {
			context.perform { [weak self] in
				do {
					try context.save()
				} catch {
					print("Context save error:\(error)")
				}
				
				if let parent = context.parent {
					self?.performSave(context: parent, completionHandler: completionHandler)
				} else {
					completionHandler?()
				}
			}
		} else {
			completionHandler?()
		}
	}
	
	/**
	Удаление объектов из Core Data по их ID
	
	- parameter objects: Массив удаляемых объектов
	*/
	class func deleteObjects(_ objects: Set<NSManagedObject>) {
		
		if objects.count > 0 {
			
			let context = sharedStorageManager.saveContext
			
			for object in objects {
				
				context?.delete(object)
			}
			
			sharedStorageManager.performSave(context: context!, completionHandler: { })
		}
	}
	
	static func findOrInsertUserModel(in context: NSManagedObjectContext) -> UserModel? {
		let templateName = "UserDataModel"
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: templateName)
		request.returnsObjectsAsFaults = false
		let user = UserModel()
		
		do {
			let result = try context.fetch(request)
			let data = result.first as? NSManagedObject
			
			user.textName = data?.value(forKey: "textName") as? String
			user.textDescript = data?.value(forKey: "textDescript") as? String
			
			if let data = data?.value(forKey: "imagePhoto") {
				user.imagePhoto = UIImage.init(data: data as! Data)
			} else {
				user.imagePhoto = UIImage.init(named: "placeholder.png")
			}
			
		} catch {
			print("Failed to fetch UserModel: \(error)")
		}
		
		return user
	}
}

extension UserModel {
	
	static func insertUserModel(in context: NSManagedObjectContext) -> NSManagedObject {
		let templateName = "UserDataModel"
		let entity = NSEntityDescription.entity(forEntityName: templateName, in: context)
		let user = NSManagedObject(entity: entity!, insertInto: context)
		return user
	}
}
