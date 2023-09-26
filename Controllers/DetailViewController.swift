//
//  DetailViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    let networkManager = NetworkManager.shared
    let databaseManager = DatabaseManager.shared
    
    var book: Book? {
        didSet{
            setupData()
            loadImage()
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
        }
        
        coverImageView.layer.cornerRadius = 5
        coverImageView.layer.borderWidth = 1
        coverImageView.clipsToBounds = true
        coverImageView.layer.borderColor = UIColor(hexCode: "EFEDED").cgColor
        
        selectButton.layer.cornerRadius = selectButton.frame.height / 2
        selectButton.clipsToBounds = true
    }
    

    func setupData(){
        if let book = book, let bookISBN = book.isbn {
            
            networkManager.getBookDescription(isbn: bookISBN ){ result in
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
    
    func loadImage() {
        if let book = book, let imgUrl = book.bookImageURL, let url = URL(string: imgUrl){
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.coverImageView.image = image
                        }
                    }
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
}
