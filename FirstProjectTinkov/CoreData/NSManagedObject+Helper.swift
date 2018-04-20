//
//  NSManagedObject+Helper.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 19.04.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import Foundation
import CoreData


protocol NSManagedObjectHelperProtocol {
    
}

extension NSManagedObject : NSManagedObjectHelperProtocol {
    
    
//    /**
//    Создание сущности в контексте
//
//    - parameter name: Имя сущности
//    - returns: NSManagedObject
//    */
//    class func createEntityInContext(_ name: String, context: NSManagedObjectContext) -> NSManagedObject {
//
//        return NSEntityDescription.insertNewObject(forEntityName: name, into: context)
//    }
//
//    /**
//    Добавление сущности в контекст
//
//    - parameter id: Идентификатор обновляемой сущности
//    - returns: NSManagedObject
//    */
//    func insertByID(_ id: String, context: NSManagedObjectContext) {
//
//        var existEntity = NSManagedObject.findEntity(self.entity.name!, id: id)
//
//        existEntity = self
//        context.insert(self)
//    }
    
    /**
    Поиск сущности в CoreData по её идентификатору
    
    - parameter name:  Имя сущности
    - parameter witID: Идентификатор сущности
    
    - returns: NSManagedObject
    */
    class func findEntity(_ name: String, id: String, context: NSManagedObjectContext) -> NSManagedObject? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = NSPredicate.init(format: "id == %@", id)
        
        var foundedObjects: AnyObject? = nil
        
        do {
            
            foundedObjects = try context.fetch(request) as NSArray
        }
        catch let error as NSError {
            
            print("Ошибка при поиске в БД", error)
        }
        
        return foundedObjects != nil ? foundedObjects!.lastObject as? NSManagedObject : nil
    }
}
