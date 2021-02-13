//
//  NoteTEST.swift
//  MyNoteBookTests
//
//  Created by Jorge Sanchez on 29/01/2021.
//

import XCTest
import CoreData
@testable import MyNoteBook


class NoteTEST: XCTestCase {
    private let  modelName = "MyNoteBook"
    private let  optionalStoreName = "NoteBooksTest"

    override func setUpWithError() throws {
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        let dataController =  DataController(modelName: modelName,
                                             optionalStoreName: optionalStoreName) { (_) in}
        dataController.deletePersistenStore()
    }

    func testCreateAndSearchNote(){
        let dataController =  DataController(modelName: modelName,
                                             optionalStoreName: optionalStoreName) { (_) in}
        
        //crear notes en nuestro view context
        dataController.loadNotesInBackground()
        
        //salbar notes del managedObjectContext
        dataController.save()
        //reset/clean up managedObjectContext
        dataController.reset()
        //buscar notes.
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let notes = dataController.fetchNotes(using: fetchRequest)
        
        XCTAssertEqual(notes?.count, 3)
    }
    
    func testNoteViewController(){
        let dataController =  DataController(modelName: modelName,
                                             optionalStoreName: optionalStoreName) { (_) in}
        let managedObjectContext =  dataController.viewContext
        
        let noteBook =  NotebookManagerObject.createNoteBook(createAt: Date(),
                                                             title: "notebook1",
                                                             in: managedObjectContext)
        let note = NoteManagerObject.createNote(managedObjectContext: managedObjectContext,
                                                notebook: noteBook!,
                                                title: "nota 1º",
                                                createAt: Date())
        
        // crear un note  viewController
        let noteViewController = NoteTableViewController(dataController: dataController)
        noteViewController.notebook = noteBook
        
        noteViewController.loadViewIfNeeded()
        let notes = noteViewController.fetchresultController?.fetchedObjects  as? [NoteManagerObject]
        
        XCTAssertEqual(notes?.count, 1)
        
        
        
    }
    

}
