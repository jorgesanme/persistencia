//
//  NoteTableViewController.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 29/01/2021.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var dataController: DataController?
    var fetchresultController: NSFetchedResultsController<NSFetchRequestResult>?
    var notebook: NotebookManagerObject?
    //se instancia un controlador de busqueda
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredNote : [ NoteManagerObject ] = []
    
    
    // se inicia el dataController a travez de un inicializador
    public convenience init(dataController: DataController){
        self.init()
        self.dataController =  dataController
    }
    
    func initializeFetchResultsController(){
        //1. declarar nuestro datacontroller
        guard let dataController = dataController else {return}
        guard let notebook =  notebook else {return}
        
        //2. crear nuestro NSfetchRequest
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        //3. setear el NSSortDescriptor. y el predicado de busqueda
        let notesCreatedAtSortDescriptor =  NSSortDescriptor(key: "createAt", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        
        fetchRequest.sortDescriptors = [notesCreatedAtSortDescriptor]
        
        //4. creamos el NSFetcheResultController
        
        
        /*
         1.- No se puede colocar "querys" de SQL nativo en los NSPredicates,
         este ya tiene sus forma de traducir el lenguaje y comunicarse con la BBDD
         2.- Solo se puede hacer una solucitudes "query" de UNO a MUCHOS en nuestro path/format en un NSPresicate.
         3.- NO  se pueden hacer sort descriptors con Properties que son Transients ( valor calculado o dependiente de otro valor de la BBDD)
         */
        
        //5. perform el fetch
        let managedObjectContext =  dataController.viewContext
        fetchresultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchresultController?.delegate = self
        
        do{
            try fetchresultController?.performFetch()
        }catch{
            fatalError("cound not find notes->  \(error.localizedDescription)")
        }
        
    }
    
    init(){
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       // fatalError("init(coder:) has not been implemented")
    }
    // se finaliza el inicializador
    
    
    //Se crear el fetchViewController para buscar los objetos y
    //escuchar los cambios en viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        //se asigna titulo a la pantalla
        title =  "List of Notes"
        initializeFetchResultsController()
        //se intancia la configuración del buscador
        setupSearchBar()
        
        //crear un boton que abra el image picker y al seleccionar una imagen,
        // se pueda agregar una nota con esa imagen
        setupNavigationItem()
        
    }
    func setupSearchBar(){
        /* === se crea la configuración del searchBar === */
        
        // 1 controlador del cambio de texto
        searchController.searchResultsUpdater = self
        // 2 se oculta el controlador de vista, no se aceptan mirones
        searchController.obscuresBackgroundDuringPresentation = false
        // 3 se define el texto hint que aparece en la barra de busqueda
        searchController.searchBar.placeholder = "Search a note"
        // 4 Se añade el buscador a la barra de navegationItem
        navigationItem.searchController = searchController
        // 5 si la barra no esta en este contexto, debe desaparecer
        definesPresentationContext = true
        
    }
    //propiedad computada compruba que el texto este empty
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //MARK: -filtrar por texto
    func filterForSearchText(predicate: String) {
        //1. declarar nuestro datacontroller
        guard let dataController = dataController else {return}
        guard let notebook =  notebook else {return}
        
        //2. crear nuestro NSfetchRequest
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        //3. setear el NSSortDescriptor. y el predicado de busqueda
        let notesCreatedAtSortDescriptor =  NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [notesCreatedAtSortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "(title CONTAINS[cd] %@) AND (notebook == %@)", predicate, notebook)
        
        
        let managedObjectContext =  dataController.viewContext
        fetchresultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchresultController?.delegate = self
        
        do{
            try fetchresultController?.performFetch()
        }catch{
            fatalError("cound not find notes->  \(error.localizedDescription)")
        }
        
        
        
        
       
    }
    
    
    func setupNavigationItem(){
        //se crea un boton (UIBarButton)
        // setear el botón con el método que llama a la funcion abrir el image Picker
        
        let addNoteBarButtonItem =  UIBarButtonItem(title:"Add Note",
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(addNote))
        
        navigationItem.rightBarButtonItem =  addNoteBarButtonItem
    }
    
    @objc
    func addNote(){
        if let notebook =  self.notebook {
            self.dataController?.createNote(notebook: notebook,
                                            title: "Titulo inicial",
                                            description: "Descripcion editable por usuario")
        }
    }
    
    @objc
    func createAndPresentImagePicker(){
        let picker = UIImagePickerController()
        picker.delegate =  self
        picker.allowsEditing =  false
        
        // se necesita presentar los mediatypes disponibles en este caso solo photolibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary),
           let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary){
            picker.mediaTypes = availableTypes
           }
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            if let selectedImage =  info[.originalImage] as? UIImage,
               let url =  info[.imageURL] as? URL{                
                // se llama al datacontroller para añadir nuestra nota y la imagen asociada
                if let notebook =  self?.notebook {
                    self?.dataController?.addNotes(with: url, notebook: notebook)
                }
            }
        }
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
    //MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let  segueIdentifier =  segue.identifier,
           segueIdentifier == "SEGUE_TO_DETAIL"{
            // encontrar el noteViewController  a usar.
            let destination =  segue.destination as! DetailViewController
            
            // encontrar el notebook que se  ha seleccionado
            let indexPathSelected =  tableView.indexPathForSelectedRow!
            guard let selectedNote = fetchresultController?.object(at: indexPathSelected) as? NoteManagerObject else {return}
            // y luego le asigna a la variable del DetailView
            // se le pasa el objeto note y su id para localizarlo segun me convenga
            destination.note = selectedNote
            destination.noteID =  selectedNote.objectID
            destination.dataController = dataController
            
        }
    }
    
    //MARK: - Segue to Detail
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // se lanza la pantalla de detalles
        performSegue(withIdentifier: "SEGUE_TO_DETAIL", sender: nil)
        
    }
    
    // se configura la celda
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "noteCellidentifier", for: indexPath)
        guard let note =  fetchresultController?.object(at: indexPath) as? NoteManagerObject else {
            fatalError("Attemp to configure cell without a manage object")
        }

        cell.textLabel?.text =  note.title
        
        if let notecreatedAt = note.createAt{
            cell.detailTextLabel?.text = HelperDateFormatter.textFrom(date: notecreatedAt)
        }
        if let photograph =  note.photograph?.allObjects.first as? PhotographMO , // relacion a Photograph
            let imageData  = photograph.imageData, //el atributo image data (donde posee la info de la imagen)
            let image = UIImage(data: imageData){ // aqui se crea el UIImage necesario para nuestra celda.
            
            cell.imageView?.image =  image // se setea la UIImage del imageView en la celda.
            
            }
           
        
        return cell
    }
}

//MARK:- Delegate extension
extension NoteTableViewController: NSFetchedResultsControllerDelegate{
    
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
extension NoteTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = self.searchController.searchBar.text else {return}
        print(searchText)
        self.filterForSearchText(predicate: searchText)
        self.tableView.reloadData()
            
        }
    }
    
    

