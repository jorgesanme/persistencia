//
//  CollectionViewCell.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 16/02/2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoView?.image =  nil
    }
    
    func configureView(image: UIImage?){
        photoView?.image = image
    }
}
