//
//  KeywordCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/26.
//

import UIKit

class KeywordCell: UICollectionViewCell {

   
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    var searchItem: SearchHistory? {
            didSet{
                setupDatas()
            }
        }
        
   var removeButtonPressed: (SearchHistory?) -> Void = { (sender) in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configureUI()
    }

    func configureUI(){
          backView.clipsToBounds = true
          backView.layer.cornerRadius = 15
        backView.backgroundColor = UIColor(hexCode: Color.lightMainColor)
        
        removeButton.tintColor = UIColor(hexCode: Color.mainColor)
      }
      
      func setupDatas(){
          if let searchData = searchItem {
              keywordLabel.text = searchData.term
            
          }
      }
      
      @IBAction func removeButtonTapped(_ sender: UIButton) {
          removeButtonPressed(searchItem)
      }
}
