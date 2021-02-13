//
//  MyNoteBookTests.swift
//  MyNoteBookTests
//
//  Created by Jorge Sanchez on 25/01/2021.
//

import XCTest

//1º paso es importar nuestro proyecto y el CoreData

import CoreData
@testable import MyNoteBook

private let  modelName = "MyNoteBook"
private let  optionalStoreName = "NoteBooksTest"


class MyNoteBookTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
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

    func testInitDatacontrollerInicializes() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        DataController(modelName: modelName, optionalStoreName: optionalStoreName) { _ in
            XCTAssert(true)
        }
    }
    
    
    func testInitNotebook() throws{
       
        DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistenContainer) in
            guard let persistenContainer =  persistenContainer else{
                XCTFail()
                return
        }
            let managedObjectContext = persistenContainer.viewContext
            
            let noteBook1 = NotebookManagerObject.createNoteBook(createAt: Date(),
                                                                 title: "notebook 1",
                                                                 in: managedObjectContext)
            XCTAssertNotNil(noteBook1)
            
        }
        
    }
    
    // test de creación de los objetos del modelo y contar cuantos se crean
    func testFetchDataController_FetchessNotebook(){
        let dataController = DataController(modelName: modelName, optionalStoreName: "NoteBooksTest") { (persistentContainer) in
            guard let managedObjectContext =  persistentContainer?.viewContext else{
                XCTFail()
                return
            }
            // se cargan los datos que estan al pie de este documento
            self.insertNotebooksInto(managedObjectContext: managedObjectContext)
        }
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebooks = dataController.fetchNoteBooks(usig: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 3)
        
    }
    
    // test de filtrado de un objeto entre la lista que objetos existentes.
    func testFilter_Datacontroller_FilterNotebooks(){
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
            }
            // se cargan los datos que estan al pie de este documento
            self.insertNotebooksInto(managedObjectContext: managedObjectContext)
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let textAComparar = "notebook 2"
        fetchRequest.predicate = NSPredicate(format: "title == %@",textAComparar)
        let notebooks = dataController.fetchNoteBooks(usig: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 1)
        
    }
    
    
    // Test de Guardado a la persistencia final. PersistentStore
    func testSaveDataContoller_SavesInPersistentStore(){
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
            }
            
        }
        //se inserta el conjunto de objetos con los datos
        dataController.loadNotebookIntoViewContext()
        // se llama al guardado de datos del managedObjectContext
        dataController.save()
        // se resetea (cleanUp) el estado de memoria managedObjectContext
        dataController.reset()
        
        // se buscan datos
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebooks = dataController.fetchNoteBooks(usig: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 3)
        
    }
    
    func testDelete_DataController_DeletesDataInPersistenStore(){
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
            }
            
        }
        //se inserta el conjunto de objetos con los datos
        dataController.loadNotebookIntoViewContext()
        // se llama al guardado de datos del managedObjectContext
        dataController.save()
        // se resetea (cleanUp) el estado de memoria managedObjectContext
        dataController.reset()
        
        // se elimina todas las referencias de todas la BBDD
        dataController.deletePersistenStore()
        
        // se buscan datos
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebooks = dataController.fetchNoteBooks(usig: fetchRequest)
        XCTAssertEqual(notebooks?.count, 0)
        
    }
    
    //MARK: - Helper Methods
    // se insertan 3 objetos de del modelo para ser reusados por los demas test
    func insertNotebooksInto(managedObjectContext: NSManagedObjectContext) {
        NotebookManagerObject.createNoteBook(createAt: Date(),
                                             title: "notebook 1",
                                             in: managedObjectContext)
        NotebookManagerObject.createNoteBook(createAt: Date(),
                                             title: "notebook 2",
                                             in: managedObjectContext)
        NotebookManagerObject.createNoteBook(createAt: Date(),
                                             title: "notebook 3",
                                             in: managedObjectContext)
        
    }
}
