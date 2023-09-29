//
//  RecKeywordCell.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/27.
//

import UIKit

class RecKeywordCell: UICollectionViewCell {
    
    
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    var keywordPressed: (String) -> Void = { (sender)  in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configureUI()
    }

    func configureUI(){
        
        let keywordClick = UITapGestureRecognizer(target: self
                                              , action: #selector(keywordTapped))
        keywordLabel.addGestureRecognizer(keywordClick)
        keywordLabel.isUserInteractionEnabled = true
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = backView.frame.height / 2
      
        backView.layer.borderColor = UIColor(.gray).cgColor
        backView.layer.borderWidth = 1
      }
    
    
    @objc func keywordTapped(){
        guard let keyword = keywordLabel.text  else { return }
        keywordPressed(keyword)
    }
}
