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
    private var blockOperation = BlockOperation()
    
    public convenience init(dataController: DataController){
        self.init()
        self.dataController =  dataController
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // se presenta el navegationItem
        setupNavigationItem()
        setupCollection()
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
        let photographCreatedAtSortDescriptor =  NSSortDescriptor(key: "createAt", ascending: true)
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
        imageCollection?.delegate = self
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
            if let url =  info[.imageURL] as? URL{
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchresultController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as? CollectionViewCell
        guard let photograph = fetchresultController?.object(at: indexPath) as? PhotographMO  else {
            fatalError("No se puede configuar la celda sin un manager object")
        }
                
        if let imageData = photograph.imageData,
           let image =  UIImage(data: imageData){
            cell?.configureView(image: image)
        }else {
            cell?.configureView(image: UIImage(named: "nilPhoto"))
        }
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - NoteDetailViewController: NSFetchedResultsControllerDelegate
extension DetailViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert:
                blockOperation.addExecutionBlock {
                    self.imageCollection?.insertSections(sectionIndexSet)
                }
            case .delete:
                blockOperation.addExecutionBlock {
                    self.imageCollection?.deleteSections(sectionIndexSet)
                }
            case .update:
                blockOperation.addExecutionBlock {
                    self.imageCollection?.reloadSections(sectionIndexSet)
                }
            case .move:
                break
            @unknown default:
                break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { break }
                blockOperation.addExecutionBlock {
                    self.imageCollection?.insertItems(at: [newIndexPath])
                }
            case .delete:
                guard let indexPath = indexPath else { break }
                blockOperation.addExecutionBlock {
                    self.imageCollection?.deleteItems(at: [indexPath])
                }
            case .update:
                guard let indexPath = indexPath else { break }
                blockOperation.addExecutionBlock {
                    self.imageCollection?.reloadItems(at: [indexPath])
                }
            case .move:
                guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
                blockOperation.addExecutionBlock {
                    self.imageCollection?.moveItem(at: indexPath, to: newIndexPath)
                }
            @unknown default: break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        imageCollection?.performBatchUpdates({
            self.blockOperation.start()
        }, completion: nil)
    }
}
















