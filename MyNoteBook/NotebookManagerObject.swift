//
//  NotebookManagerObject.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 26/01/2021.
//

import Foundation
import CoreData

public class NotebookManagerObject: NSManagedObject{
    
    // para insertar los datos al despertarse la app
    // uniquing: todos los managedObject representan un solo registro en nuestro persistentStore
    //
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        print ("se ha creado un Notebook")
        createdAt =  Date()
        createdAtHumanReadable = HelperDateFormatter.textFrom(date: createdAt!)
    }
    
    // los datos que no se pueden mostrar por desborde de memoria
    // o cuando deja de existir en memoria.
    // Fault: representan los objetos que referencian a registros en nuestro persistenStore,
    // pero que no estan cargados en memoría.
    public override func didTurnIntoFault() {
        super.didTurnIntoFault()
        print ("se ha producido un fault")
    }
    
    
    
    // Binary Large Data Objects (BLOBs)
            // Registro dentro de nuestro NSPersistentStore (sqlite) > 1 MB.
            // CLOB Character Large Object de 128 bytes. (1 million de registro) es considerado un BLOBs.
            // normalizar con una tabla.
            // SQLite Store puede aumentar su tamaño 100 GB.
            // El normalizar los objetos en otra table aumenta los beneficios del Faulting.
            // a veces es mejor usar una URL a la imagen que queramos cargar.
    
    
    @discardableResult
    static func createNoteBook(createAt: Date,
                               title: String,
                               in managedObjectContext: NSManagedObjectContext)-> NotebookManagerObject?{
        
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: managedObjectContext) as? NotebookManagerObject
       
        
        notebook?.createdAt = createAt
        notebook?.title =  title
        return notebook
    }
    
}
