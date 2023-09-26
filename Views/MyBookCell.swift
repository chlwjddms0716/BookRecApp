//
//  MyBookCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/25.
//

import UIKit

class MyBookCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var book: Book? {
        didSet{
            setupDatas()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    func configureUI(){
        
        coverImageView.layer.borderColor = UIColor(hexCode: "EFEDED").cgColor
        coverImageView.layer.borderWidth = 1
        
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 5
        
    }
    
    func setupDatas(){
        
        if let book = book {
            titleLabel.text = book.title
            authorLabel.text = book.authors
            
            UIImage().loadImage(imageUrl: book.bookImageURL){ image in
                DispatchQueue.main.async {
                    self.coverImageView.image = image
                }
            }
        }
    }
    
}
