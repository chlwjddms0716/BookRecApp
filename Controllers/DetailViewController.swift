//
//  DetailViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    private let networkManager = NetworkManager.shared
    private let databaseManager = DatabaseManager.shared
    
    var book: Book? {
        didSet{
            setupData()
            //loadImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI(){
        
        if let book = book{
            titleLabel.text = book.title
            authorLabel.text = book.authors
            
            UIImage().loadImage(imageUrl: book.bookImageURL, completion: { image in
                DispatchQueue.main.async {
                    self.coverImageView.image = image
                }
            })
        }
        
        coverImageView.layer.cornerRadius = 5
        coverImageView.layer.borderWidth = 1
        coverImageView.clipsToBounds = true
        coverImageView.layer.borderColor = UIColor(hexCode: "EFEDED").cgColor
        
        selectButton.layer.cornerRadius = 10
        selectButton.clipsToBounds = true
        selectButton.backgroundColor =  UIColor(hexCode: Color.mainColor)
        selectButton.setTitleColor(.white, for: .normal)
        
        backView.clipsToBounds = true
        backView.backgroundColor = UIColor(hexCode: Color.bookBackColor)
        
        titleLabel.textColor = .black
        authorLabel.textColor = .lightGray
        closeButton.tintColor = UIColor(hexCode: Color.mainColor)
    }
    
    
    func setupData(){
        if let book = book, let bookISBN = book.isbn {
            
            networkManager.fetchBookDescription(isbn: bookISBN ){ result in
                switch result{
                case .success(let bookData):
                    
                    print(bookData)
                    DispatchQueue.main.async {
                        self.descriptionLabel.text = bookData
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            
        }
    }
    
   
    // MARK: - 서재에 담기 버튼 클릭
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        
        if let bookData = book, let bookIsbn = bookData.isbn {
            databaseManager.insertSelectBook(bookIsbn: bookIsbn) {  result in
                
                var alertMsg = ""
                switch result {
                case .success(_) :
                    alertMsg = "도서 담기 성공하였습니다."
                case .failure(let error) :
                    alertMsg = error == DatabaseError.existBookError ? "이미 서재에 추가된 도서입니다." : "도서 담기 실패하였습니다.\r\n다시 시도해주세요."
                }
                
                let alert = UIAlertController(title: "도서 서재에 담기", message: alertMsg, preferredStyle: .alert)
                
                let success = UIAlertAction(title: "확인", style: .default) { action in
                    self.dismiss(animated: true)
                }
                
                alert.addAction(success)
                self.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
