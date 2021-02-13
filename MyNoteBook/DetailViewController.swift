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
        //1.- Safe unwrappin el Datacontroller y el note
//        guard let dataController = dataController,
//                 let note =  note else{return}
//
//        //2.- crear NSFetchRequest para la nota
//        //   buscar la nota
//        let fetchNote =  NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
//        let notes = dataController.fetchNotes(using: fetchNote)
//
//        //3.- se crea un NSSortDescriptior.
//        // esto podrias usarse para atraer las photograph
//        let noteNameSort =  NSSortDescriptor(key: "title", ascending: true)
//
        //4.- creamos el NSFetchResultController
        
        //5.- Perfom el fetch
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.text = note?.title
        descriptionTextArea.text = note?.noteDescripcion
        
        
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
            if let selectedImage =  info[.originalImage] as? UIImage,
               let url =  info[.imageURL] as? URL{
                
                // se llama al datacontroller para añadir nuestra nota y la imagen asociada
                if let note =  self?.note {
                    self?.dataController?.addPhotograph(with: url, note: note)
                }
                
            }
        }
        
    }
}

//extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//    }
//    
//    
//}
