//
//  bookCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class bookCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var bookData: Book?{
        didSet{
            setupDatas()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 일반적으로 이미지가 바뀌는 것처럼 보이는 현상을 없애기 위해서 실행 ⭐️
        self.bookCoverImageView.image = nil
    }
    
    func configureUI(){
        
        bookCoverImageView.layer.borderColor = UIColor(hexCode: "EFEDED").cgColor
        bookCoverImageView.layer.borderWidth = 1
        
        bookCoverImageView.clipsToBounds = true
        bookCoverImageView.layer.cornerRadius = 5
        
    }
    
    func setupDatas(){
        
        if let book = bookData {
            rankLabel.text = book.ranking
            authorLabel.text = book.authors
            titleLabel.text = book.title
            
            UIImage().loadImage(imageUrl: book.bookImageURL){ image in
                DispatchQueue.main.async {
                    self.bookCoverImageView.image = image
                }
            }
        }
    }
}
