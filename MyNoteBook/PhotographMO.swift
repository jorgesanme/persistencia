//
//  PhotographMO.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 03/02/2021.
//

import UIKit
import CoreData


public class PhotographMO: NSManagedObject {
    
    static func createPhoto(imageData: Data,
                            managedObjectContext:NSManagedObjectContext) -> PhotographMO{
        let photograph =  NSEntityDescription.insertNewObject(forEntityName: "Photograph", into: managedObjectContext) as? PhotographMO
        
        photograph?.imageData = imageData
        return photograph!
        
    }

}
