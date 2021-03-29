//
//  DetailViewController.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 09/02/2021.
//

import UIKit
import CoreData


class DetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var imageCollection: UICollectionView!
    
    var dataController: DataController?
    var fetchresultController: NSFetchedResultsController<NSFetchRequestResult>?
    var note: NoteManagerObject?
    var noteID: NSManagedObjectID?
    var blockOperations: [BlockOperation] = []
    
    private var indexPath = IndexPath()
    
    
    public convenience init(dataController: DataController){
        self.init()
        self.dataController =  dataController
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // se presenta el navegationItem
        setupNavigationItem()
        //se asigna titulo a la pantalla
        title = "Details"
        initializeFetchResultsController()
        
    }
    func initializeFetchResultsController(){
        //1. declarar nuestro datacontroller
        guard let dataController = dataController else {return}
        guard let note =  note else {return}
        
        //2. crear nuestro NSfetchRequest
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Photograph")
        
        //3. setear el NSSortDescriptor. y el predicado de busqueda
        let photographCreatedAtSortDescriptor =  NSSortDescriptor(key: "imageData", ascending: true)
        fetchRequest.sortDescriptors = [photographCreatedAtSortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "note == %@", note)
                
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.text = note?.title
        descriptionTextArea.text = note?.noteDescripcion
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        note?.title =  titleTextField.text
        note?.noteDescripcion = descriptionTextArea.text
    }
    
    private func setupCollection(){
        imageCollection?.dataSource =  self
    }
    
    
    func setupNavigationItem(){
        //se crea un boton (UIBarButton)
        // setear el botón con el método que llama a la funcion abrir el image Picker
        
        let addNoteBarButtonItem =  UIBarButtonItem(title:"Add Image",
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(createAndPresentImagePicker))
        
        navigationItem.rightBarButtonItem =  addNoteBarButtonItem
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
            guard let self = self else {return}
            if let selectedImage =  info[.originalImage] as? UIImage,
               let url =  info[.imageURL] as? URL{
                // se llama al datacontroller para añadir nuestra nota y la imagen asociada
                if let note =  self.note {
                    self.dataController?.addPhotograph(with: url, note: note)
                }
            }
        }        
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fetchresultController =  fetchresultController{
            return
                fetchresultController.sections![section].numberOfObjects
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  imageCollection?.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as? CollectionViewCell
        guard let photograph = fetchresultController?.object(at: indexPath) as? PhotographMO  else {
            fatalError("No se puede configuar la celda sin un manager object")
        }
        
        if let imageData = photograph.imageData, //photograph.imageData  o note?.photograph?.imageData
           let image =  UIImage(data: imageData){
            cell?.configureView(image: image)
        }else {
            cell?.configureView(image: UIImage(named: "nilPhoto"))
        }
        return cell ?? UICollectionViewCell()
    }
    
    
}

extension DetailViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }

    // did change a section. al cambiar una sección
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    })
                )
            case .delete:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    })
                )
            //imageCollection?.deleteSections(IndexSet(integer: sectionIndex))
            case .move, .update:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    })
                )
            @unknown default: fatalError()
        }
    }

    // did change an object.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        self.indexPath = newIndexPath ?? IndexPath()
        switch type {
            case .insert:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.insertItems(at: [newIndexPath!])
                        }
                    })
                )
            case .delete:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.deleteItems(at: [indexPath!])
                        }
                    })
                )
            case .update:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.reloadItems(at: [indexPath!])
                        }
                    })
                )
            case .move:
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            this.imageCollection?.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    })
                )
            @unknown default:
                fatalError()
        }
    }

    // did change content.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        imageCollection?.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
}
