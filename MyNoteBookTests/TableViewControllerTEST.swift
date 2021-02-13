//
//  TableViewControllerTEST.swift
//  MyNoteBookTests
//
//  Created by Jorge Sanchez on 28/01/2021.
//

import XCTest
import CoreData
@testable import MyNoteBook

class TableViewControllerTEST: XCTestCase {
    private let  modelName = "MyNoteBook"
    private let  optionalStoreName = "NoteBooksTest"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    override func tearDownWithError() throws {
        //Se elimina todos los datos al terminar el test
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in
            guard let persistentContainer = persistentContainer else {
               fatalError("could not delete test database.")
                
            }
            let whichStore =  persistentContainer.persistentStoreCoordinator.persistentStores[0]
            let persistentStoreUrl = persistentContainer.persistentStoreCoordinator.url(for: whichStore)
            
            do{
                try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: persistentStoreUrl, ofType: NSSQLiteStoreType, options: nil)
            }catch{
                fatalError("Could not delete test Database. \(error.localizedDescription)")
            }
            
        }
        
    }
    
    func testFetchResultController_FetchNotesInViewContext_InMemory(){
        let dataController = DataController(modelName: modelName,
                                            optionalStoreName: optionalStoreName) { (pers) in}
        
        dataController.loadNotebookIntoViewContext()
        let notebookViewController =  NoteBookTableViewController(dataController: dataController)
        
        notebookViewController.loadViewIfNeeded()
        
        let foundNotesBooks = notebookViewController.fetchresultController?.fetchedObjects?.count
        
        XCTAssertEqual(foundNotesBooks, 3)
    }
    
    func testFetchResultController_FetchNotesInViewContext_InPersistenStore(){
        let dataController = DataController(modelName: modelName,
                                            optionalStoreName: optionalStoreName) { (pers) in}
        
        // se cargan los datos y
        dataController.loadNotebookIntoViewContext()
        //se guardan en Persistente
        dataController.save()
        // Se limpia la memoria clean up del viewContext
        dataController.reset()
        
        // se crea el viewController y su fetchResultController
        let notebookViewController =  NoteBookTableViewController(dataController: dataController)
        
        // pedimos que se carge la vista de nuestro ViewController, por lo tanto ejecuta el viedDidLoad()
        // y por lo tanto hace que el fetchresultsController empiece a buscar.
        notebookViewController.loadViewIfNeeded()
        
        // comparamos entonces los resultados.
        let foundNotesBooks = notebookViewController.fetchresultController?.fetchedObjects?.count        
        XCTAssertEqual(foundNotesBooks, 3)
    }
    
}
