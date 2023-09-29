//
//  SearchCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class SearchCell: UITableViewCell {

    
    @IBOutlet weak var backView: UIView!
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
        
        self.backgroundColor = UIColor(hexCode: Color.grayColor)
        
        coverImageView.layer.borderColor = UIColor(hexCode: Color.imageBorderColor).cgColor
        coverImageView.layer.borderWidth = 1
        
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = RadiusNumber.imageRadiusNum
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10
        
        backView.layer.masksToBounds = false
        backView.layer.shadowRadius = 4
        backView.layer.shadowOpacity = 0.2
        backView.layer.shadowColor = UIColor.gray.cgColor
        backView.layer.shadowOffset = CGSize(width: 0 , height:2)
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
