//
//  MyViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit
import FirebaseAuth

class MyViewController: UIViewController {

    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
   private let networkManager = NetworkManager.shared
    
  private  let databaseManager = DatabaseManager.shared
  private  var bookArray: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        configureUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        
        setUserInfo()
        getBookData()
    }
    
    func showIndicator(){
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.startAnimating()
    }
    
    func hideIndicator(){
        loadingIndicatorView.isHidden = true
        loadingIndicatorView.stopAnimating()
    }
    
    func getBookData(){
        bookArray = []
        DispatchQueue.main.async {
            self.myCollectionView.reloadData()
        }
        
        if Auth.auth().currentUser != nil {
            showIndicator()
            self.guideLabel.isHidden = true
            
            databaseManager.getSelectBook { bookData in
                if let books = bookData {
                    self.networkManager.fetchMyBookList(bookList: books) {  bookData in
                        self.bookArray = bookData
                        
                        DispatchQueue.main.async {
                            self.hideIndicator()
                            self.myCollectionView.reloadData()
                            self.guideLabel.isHidden = true
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.hideIndicator()
                        self.guideLabel.isHidden = false
                        self.guideLabel.text = "도서를 서재에 담아보세요!"
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                self.hideIndicator()
            }
        }
    }
    
    func configureUI(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didDismissLoginNotification(_:)),
            name: NSNotification.Name("DismissLoginView"),
            object: nil
        )
        
        guideLabel.textColor = .gray
        guideLabel.text = "로그인하여 내 서재를 확인해보세요!"
        
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        
        logoutButton.clipsToBounds = true
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
    }
    
    func setupCollectionView(){
        
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .white
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionCellWidth = (UIScreen.main.bounds.width - CVCell.spacingWitdh * (CVCell.cellColumns - 1)) / CVCell.cellColumns
        flowLayout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth + CVCell.addHeight )
        flowLayout.minimumInteritemSpacing = CVCell.spacingWitdh
        flowLayout.minimumLineSpacing = CVCell.spacingWitdh

        myCollectionView.collectionViewLayout = flowLayout
    }
    
    
    @objc func didDismissLoginNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.setUserInfo()
        }
    }
    
    func setUserInfo(){
        
        if let user = Auth.auth().currentUser {
            DispatchQueue.main.async {
                self.setLoginUI(user: user)
            }
        }
        else{
            DispatchQueue.main.async {
                self.setLogoutUI()
            }
        }
    }
    
    // MARK: - 로그인 버튼 클릭 -> 화면 이동
    @objc func loginButtonTapped(){
       
        guard let loginVC = storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else { return }
        self.present(loginVC, animated: true)
    }
    
    // MARK: - 로그아웃 버튼 클릭
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("로그아웃 완료")
            
            DispatchQueue.main.async {
                self.setLogoutUI()
            }
        } catch let signOutError as NSError {
            print("로그아웃 Error발생:", signOutError)
        }
    }
    
    func setLoginUI(user: User){
        
        print("로그인 이용자 : \(String(describing: user.displayName))")
        
        nameLabel.textColor = .black
        nameLabel.text = user.displayName ?? "이용자"
      
        
        UIImage().loadImage(imageUrl: user.photoURL?.absoluteString, isUser: true){ image in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
        
        nameLabel.gestureRecognizers = nil
        self.logoutButton.isHidden = false
        
        getBookData()
    }
    
    func setLogoutUI(){
        
        print("이용자 로그인 X")
        
        nameLabel.textColor = .gray
        nameLabel.text = "로그인하기"
        guideLabel.isHidden = false
        
        userImageView.image = nil
        
        if nameLabel.gestureRecognizers == nil {
            let loginGes = UITapGestureRecognizer(target: self
                                                  , action: #selector(loginButtonTapped))
            nameLabel.addGestureRecognizer(loginGes)
            nameLabel.isUserInteractionEnabled = true
        }
        
        self.logoutButton.isHidden = true
        
        bookArray = []
        DispatchQueue.main.async {
            self.myCollectionView.reloadData()
        }
    }
}

extension MyViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return bookArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.myBookCellIdentifier, for: indexPath) as? MyBookCell else { return UICollectionViewCell() }
        cell.removeButtonPressed = { book in
            self.bookArray.removeAll(where: {$0.isbn == book.isbn})
            DispatchQueue.main.async {
                self.myCollectionView.reloadData()
                if self.bookArray.count == 0 {
                    self.guideLabel.isHidden = false
                    self.guideLabel.text = "도서를 서재에 담아보세요!"
                }
            }
            self.databaseManager.removeMyBook(bookData: book) {
                print("내 서재 도서 삭제 완료")
            }
        }
        
        cell.book = bookArray[indexPath.row]
        
        return cell
    }
}


