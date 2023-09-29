//
//  MyBookCell.swift
//  BookRecApp
//
//  Created by 최정은 on 9/29/23.
//

import UIKit

class MyBookCell: UITableViewCell {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
      @IBOutlet weak var titleLabel: UILabel!
      @IBOutlet weak var authorLabel: UILabel!
      
      var removeButtonPressed: (Book) -> Void = { (sender) in }
      
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
          
          //self.backgroundColor = UIColor(hexCode: Color.grayColor)
          
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
          
          removeButton.tintColor = UIColor(hexCode: Color.mainColor)
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
      
      @IBAction func removeButtonTapped(_ sender: UIButton) {
          if let bookData = book {
              removeButtonPressed(bookData)
          }
      }
  }
