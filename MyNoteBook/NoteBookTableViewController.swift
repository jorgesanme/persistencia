//
//  NoteBookTableViewController.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 28/01/2021.
//

import UIKit
import CoreData


class NoteBookTableViewController: UITableViewController {
    
    var dataController: DataController?
    var fetchresultController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // se inicia el dataController a travez de un inicializador
    public convenience init(dataController: DataController){
        self.init()
        self.dataController =  dataController
    }
    
    init(){
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       // fatalError("init(coder:) has not been implemented")
    }
    
    
    //Se crear el fetchViewController para buscar los objetos y
    //escuchar los cambios en viewContext
    func initializerFetchResultController(){
        guard let dataController =  dataController else{return}
        let viewContext = dataController.viewContext
        // se crea un fetchResultController
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        // es necesario tener un descriptor de la entidad para organizarlo
        let notebookSortDescriptor =  NSSortDescriptor(key: "title",
                                                       ascending: true)
        // se pueden usar otros key para identificar el orden
        request.sortDescriptors = [notebookSortDescriptor]
        
        // Formas de mitigar el Fault Overhead:
                    // Notebook -> notes -> [(fault Note), (fault Note), (fault Note)]
                    // notebook.notes.first === Coredata buscar esa note dentro NSPersistentStore -> NoteMO.
                    // significa que tienes problems de performance. ()
                    // Cuando vayamos a pedir datos de un (fault Note). Es cuando disparamos un Fault fetch.
                
                    //Batch Faulting. // let notes = [(fault Note), (fault Note), (fault Note)].
                    // Se usa para filtrar Objetos faults. El Batch Faulting nos devuelve un array con los objetos cargados en memoria.
                    // let predicate = NSPredicate(format: "self IN %@", notes)
                
                    //Prefetching. // NotebookMO -> notes -> [NoteMO, NoteMO, NoteMO].
                    //fetRequest.relationKeyPathForPrefetching = ["notes"]

        // Cuando vayamos a pedir datso de un (fault Note). es cuando disparamos un Fault fetch.
        
        
        
        // se necesita el managedObjectContext
        self.fetchresultController =  NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        do{
            try self.fetchresultController?.performFetch()
        }catch{
            print("Error while trying to perform a notebook fetch.")
        }
        
        self.fetchresultController?.delegate = self
        
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //se asigna titulo a la pantalla
        title =  "Books"
        // se inicia el fetchResult
        initializerFetchResultController()
        
        // se crea un botón en el nav Item para carga data
                // crear un barButtonItem
                // darle su funcionalidad
                // llamar a data controller para cargar los datos
//MARK: - Button Create Notebook
        let createNoteBookBarButtonItem =  UIBarButtonItem(title:"New NoteBook",
                                                    style: .done,
                                                    target: self,
                                                    action: #selector (loadData))
        
        navigationItem.rightBarButtonItem = createNoteBookBarButtonItem
        
        // otro botón  en el nav Item para borrar data.
                // crear un barButtonItem
                // darle su funcionalidad
                // llamar a data controller para cargar los datos
        
//MARK: - Button Detele Data
        let removeDataBarButtonItem =  UIBarButtonItem(title: "RemoveData",
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(removeData))
        //navigationItem.leftBarButtonItem = removeDataBarButtonItem
 
      
//MARK: - Button create Data
        
        let loadDataBarButtonItem = UIBarButtonItem(title: "LoadData",
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(loadData))

        //una opcion para colocar los Item  (mejor para iconos, no texto)
        navigationItem.leftBarButtonItems = [createNoteBookBarButtonItem, removeDataBarButtonItem, loadDataBarButtonItem]
    }
    @objc
    func loadData(){
        
        //se llama al datacontroller para que carge en background
        dataController?.loadNotesInBackground()
        
    }
    
    @objc
    func removeData(){
        // se salva todo lo que este en memoria andes de eliminar
        dataController?.save()
        //se llama al datacontroller para que elimine los datos desde el persisten
        dataController?.deletePersistenStore()
        // se resetea la memoria para que no quede nada pendiente
        dataController?.reset()
        //se llama al inicializador para recargar la View
        initializerFetchResultController()
        tableView.reloadData()
    }
    
    //Se extrae  la cantidad de  secciones que existe
    override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchresultController?.sections?.count ?? 0
    }
    // se extrae la cantidad de objetos por sercciones
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchresultController = fetchresultController{
            return fetchresultController.sections![section].numberOfObjects
        }else{
            return 0
        }
    }
    // se configura la celda

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "notebookCell", for: indexPath)
        guard let notebook =  fetchresultController?.object(at: indexPath) as? NotebookManagerObject else {
            fatalError("Attemp to configure cell without a manage object")
        }

        cell.textLabel?.text =  notebook.title
        
        if let createdAt = notebook.createdAt{
            cell.detailTextLabel?.text = HelperDateFormatter.textFrom(date: createdAt)
        }
        //MARK: -Photograph -> para poner la foto en el notebook
        if let photograph =  notebook.photograph,
           let imageData =  photograph.imageData,
           let image =  UIImage(data: imageData){
            cell.imageView?.image = image
            
        }
        
        return cell
    }
    //MARK: -NAVIGATION TO NOTE
    // PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let  segueIdentifier =  segue.identifier,
           segueIdentifier == "SEGUE_TO_NOTE"{
            // encontrar el noteTableViewController  a usar.
            let destination =  segue.destination as! NoteTableViewController
            // encontrar el notebook que se selecciona
            let indexPathSelected =  tableView.indexPathForSelectedRow!
            let selectedNoteBook = fetchresultController?.object(at: indexPathSelected) as! NotebookManagerObject
            // y luego set-tear el notebook.
            destination.notebook = selectedNoteBook
            // luego el set-tear el dataController
            destination.dataController =  dataController
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SEGUE_TO_NOTE", sender: nil)
    }
    
}

//MARK:- Delegate extension
extension NoteBookTableViewController: NSFetchedResultsControllerDelegate{
    
    // will change
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    //did change a section
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move:
                break
            case .update:
                break
            @unknown default:
                fatalError()
        }
    }
    //did change a object
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default: fatalError()
        }
    }
    
    //did change context
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
