//
//  PhotographMO+CoreDataProperties.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 03/02/2021.
//
//

import Foundation
import CoreData


extension PhotographMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotographMO> {
        return NSFetchRequest<PhotographMO>(entityName: "Photograph")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var note: NoteManagerObject?
    @NSManaged public var notebook: NotebookManagerObject?

}

extension PhotographMO : Identifiable {

}
