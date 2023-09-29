//
//  CategoryCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/27.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    var category: Category? {
        didSet{
            setupData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configureUI()
    }

    func configureUI(){
        backView.clipsToBounds = true
        backView.backgroundColor = UIColor(hexCode: Color.grayColor)
        backView.layer.cornerRadius = 5
        
        imageBackView.clipsToBounds = true
        imageBackView.layer.cornerRadius = imageBackView.frame.width / 2
        
       
    }
    
    func setupData(){
        if let categoryData = category {
            categoryLabel.text = categoryData.word
            iconImageView.image = categoryData.icon
            
            DispatchQueue.main.async {
                self.iconImageView.tintColor = UIColor(hexCode: Color.mainColor)
            }
           
        }
    }
}
