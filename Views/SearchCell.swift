//
//  SearchCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class SearchCell: UITableViewCell {

    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
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

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 일반적으로 이미지가 바뀌는 것처럼 보이는 현상을 없애기 위해서 실행 ⭐️
        self.coverImageView.image = nil
    }

    func configureUI(){
        
        coverImageView.layer.borderColor = UIColor(hexCode: "EFEDED").cgColor
        coverImageView.layer.borderWidth = 1
        
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 5
        
    }
    
    func setupDatas(){
        
        if let book = bookData {
            authorLabel.text = book.authors
            titleLabel.text = book.title
            
            UIImage().loadImage(imageUrl: book.bookImageURL){ image in
                DispatchQueue.main.async {
                    self.coverImageView.image = image
                }
            }
        }
    }
}
