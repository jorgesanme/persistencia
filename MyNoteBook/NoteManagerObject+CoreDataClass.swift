//
//  NoteManagerObject+CoreDataClass.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 27/01/2021.
//

import Foundation
import CoreData

@objc(NoteManagerObject)
public class NoteManagerObject: NSManagedObject{
    @discardableResult
    static func createNote(managedObjectContext: NSManagedObjectContext,
                           notebook: NotebookManagerObject,
                           title: String,
                           noteDescripcion: String,
                           createAt: Date) -> NoteManagerObject? {
    
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note",
                                                       into: managedObjectContext) as? NoteManagerObject
        note?.title = title
        note?.createAt = createAt
        note?.notebook = notebook
        note?.noteDescripcion = noteDescripcion
        
        return note
    }
    
}
