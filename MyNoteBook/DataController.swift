//
//  DataController.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 25/01/2021.
//

import Foundation
import CoreData
import UIKit

class DataController: NSObject{
    private let persistenContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext{
        return persistenContainer.viewContext
    }
    
    // Multi-threading y porque?
    // nos permite ejecutar código en paralelo .
    // no nos vamos a enfocar en performance pero en predecir lo que el usuario necesitará
    // y cargar los datos en background
    // La UI o main thread necesita un "view" o "main"context que viva támbien en el main thread pero
    // que támbien sea nuestro source of truth.
    //
    // NSMainQueueConcurrencyType vs NSPrivateQueueConcurrency.
    
    // Seial queues vs concurrency queues.
    // Secial queues nos permite ejecutar las tareas que le indiquemos al queue en orden.
    // las ConcurrencyQueues van a ejecutar las tareas en paralelo  mientras vayan siendo registradas
    // en nuestro Queue.
    
    
    
    @discardableResult
    init(modelName: String, optionalStoreName: String?, completionHandler: (@escaping (NSPersistentContainer?) -> () )) {        
        if let optionalStoreName = optionalStoreName{
            let managedObdjectModel = Self.managedObdjectModel(with: modelName)
            persistenContainer =  NSPersistentContainer(name: optionalStoreName,
                                                        managedObjectModel: managedObdjectModel)
            // falta poner el inicializador de datos para los test
            super.init()
            persistenContainer.loadPersistentStores {[weak self] (descripcion, error) in
                if let error = error{
                    fatalError("Couldn´t load CoreData Stack \(error.localizedDescription)")
                }
                
                completionHandler(self?.persistenContainer)
            }
                        
        }else {
            // se inician los datos con carga en background en async para uso de la app
            self.persistenContainer =  NSPersistentContainer(name: modelName)            
            super.init()
            
            DispatchQueue.global(qos: .userInitiated).async {  [weak self] in
                self?.persistenContainer.loadPersistentStores {[weak self] (descripcion, error) in
                    if let error = error{
                        fatalError("Couldn´t load CoreData Stack \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        completionHandler(self?.persistenContainer)
                    }
                    
                }
            }
            
        }
            
            
    }
    
    func fetchNoteBooks(usig fetchRequest: NSFetchRequest<NSFetchRequestResult>)-> [NotebookManagerObject]?{
        
        do{
            return try persistenContainer.viewContext.fetch(fetchRequest) as? [NotebookManagerObject]
        }catch{
            fatalError("Failure to fetch notebooks with context: \(fetchRequest), \(error)")
        }
        
        
    }
    func fetchNotes(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) ->[NoteManagerObject]?{
        do {
            return try viewContext.fetch(fetchRequest) as? [NoteManagerObject] 
        }catch{
            fatalError("Failure to fetch note with context: \(fetchRequest), \(error)")
        }
        
    }
    func fetchPhoto(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) ->[PhotographMO]?{
        do {
            return try viewContext.fetch(fetchRequest) as? [PhotographMO]
        }catch{
            fatalError("Failure to fetch note with context: \(fetchRequest), \(error)")
        }
        
    }
    
    func save(){
        do {
            //se llama al metodo que guarda en persistencia
            try persistenContainer.viewContext.save()
        }catch{
            print("=== Could not Save view context ===")
            print("error: \(error.localizedDescription) ")
        }
        
    }
    
    func reset(){
        // se resetea el contenido de la memoria de context.
        persistenContainer.viewContext.reset()
    }
    
    func deletePersistenStore(){
        let persitentStoreUrl =  persistenContainer.persistentStoreCoordinator.url(for: persistenContainer.persistentStoreCoordinator.persistentStores[0])
        do{
            try persistenContainer.persistentStoreCoordinator.destroyPersistentStore(at: persitentStoreUrl, ofType: NSSQLiteStoreType, options: nil)
        }catch{
            fatalError("Could not delete test database. \(error.localizedDescription)")
        }
    }
    
    //MARK: -momd propia: funcion que crea una url para almacenar los datos en carpeta seleccionada
     static func managedObdjectModel(with name: String) -> NSManagedObjectModel{
        guard let modelUrl =  Bundle.main.url(forResource: name, withExtension: "momd") else {
            fatalError("Error could not find model.")
        }
        guard let managedObdjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Error no se ha podido instanciar el managedObdjectModel desde: \(modelUrl).")
        }
        return managedObdjectModel
    }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext)->Void){
    // se crea un managedObjectContext privado -> background
        let privateMOC =  NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        //set nuestro viewContext
        privateMOC.parent = viewContext
        //ejetuamos el block dentro de este privateMOC
        privateMOC.perform {
            block(privateMOC)
        }
    }
    
}

// extencion que cargará datos en el viewContext para realizar pruebas
extension DataController {
       
    
    func loadNotesInBackground(){
        
        performInBackground { (managedObjectCotenxt) in
            let managedObjetContext = managedObjectCotenxt
            
            //instanciar o crear nuestros Note en el viewContext
            guard let notebook = NotebookManagerObject.createNoteBook(createAt: Date(),
                                                                      title: "notebook Con Notas",
                                                                      in: managedObjetContext) else {return}
            
//            NoteManagerObject.createNote(managedObjectContext: managedObjetContext,
//                                         notebook: notebook,
//                                         title: "nota 1º de test", noteDescripcion: "descripcion1",
//                                         createAt: Date())
//
            
            //1.- para crear una imagen
            let notebookImage =  UIImage(named: "notebooksimg")
            //2.- se crea una data extraida desde la imagen
            //3.- y se crea la imagen. Luego se asigna al notebook
            if let dataNotebookImage =  notebookImage?.pngData(){
                let photograph = PhotographMO.createPhoto(imageData: dataNotebookImage, managedObjectContext: managedObjetContext)
                
                //dos formas de añadir la imagen al notebook
                //photograph?.notebook =  notebook
                notebook.photograph =  photograph
            }
            
            do{
                try managedObjetContext.save()
            }catch{
                fatalError("No se ha podido guardar los datos en el background")
            }
        }
    }
    
    
    func loadNotebookIntoViewContext (){
        
        let managedObjectContext = persistenContainer.viewContext
        
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
    
    func addNotes(with urlImage: URL, notebook: NotebookManagerObject){
        
        //ser crea un instancia en background para reducir la carga de imagen
        performInBackground { (managedObjectContext) in
            // se crea una imagen desde la relación en los atributos de una note.
            // se usa el DownSampler para reducir el tamaño y peso de la imagen
            guard let imageThumbnail = DownSampler.downsample(imageAt: urlImage), // se consigue una UIIMage
                  //se extrae la Data desde la UIImage
                  let imageThumbnailData = imageThumbnail.pngData() else {
                return
            }
            
            // c/u de los managedObjectContext representa un registro en nuestro persisten store.
            // utilizando el objectID dle objeto nuestro managedObjectCotnex puede recrear
            // el objeto en su grafo
            let notebookId = notebook.objectID
            let copyNotebook = managedObjectContext.object(with: notebookId) as! NotebookManagerObject      
            let photographMO =  PhotographMO.createPhoto(imageData: imageThumbnailData,
                                                       managedObjectContext: managedObjectContext)
            
            let note = NoteManagerObject.createNote(managedObjectContext: managedObjectContext,
                                                    notebook: copyNotebook,
                                                    title: "Titulo de nota",
                                                    noteDescripcion: "Descripcion de la nota",
                                                    createAt: Date())
            
            note?.photograph = photographMO
            
            // una vez que se termina de cargar en el background la imagen, se le comunica al padre
            // que esta en el main para que lo guarde.
            do{
               try managedObjectContext.save()
            }catch{
            fatalError("No se ha podido crear el Thumbnail de la imagen solicitada")
            }
            
        }
    }
    
    func addPhotograph(with urlImage: URL, note: NoteManagerObject){
        performInBackground { (managedObjetContext) in
            guard let imageThumbnail =  DownSampler.downsample(imageAt: urlImage),
                  let imageThumbnailData =  imageThumbnail.pngData() else {
                return
            }
               
            let photographMO = PhotographMO.createPhoto(imageData: imageThumbnailData,
                                                        managedObjectContext: managedObjetContext)
            note.photograph = photographMO
            
            do{
                try managedObjetContext.save()
            }catch{
                fatalError("No se ha podigo guardar la imagen")
            }
            self.save()
        }
        
    }
    func createNote(notebook: NotebookManagerObject,title: String, description: String){
        performInBackground { (managedObjectContext) in
            let notebookId = notebook.objectID
            let copyOfNotebook = managedObjectContext.object(with: notebookId) as! NotebookManagerObject
            
            let note =  NoteManagerObject.createNote(managedObjectContext: managedObjectContext,
                                                     notebook: copyOfNotebook,
                                                     title: title,
                                                     noteDescripcion: description,
                                                     createAt: Date())
            do{
                try managedObjectContext.save()
            }catch{
                fatalError("No se ha podido crear la nota")
            }
        }
    }
}
