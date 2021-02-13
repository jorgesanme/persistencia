//
//  NoteManagerObject+CoreDataProperties.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 27/01/2021.
//
//

import Foundation
import CoreData


extension NoteManagerObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteManagerObject> {
        return NSFetchRequest<NoteManagerObject>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var notebook: NotebookManagerObject?

}

extension NoteManagerObject : Identifiable {

}
