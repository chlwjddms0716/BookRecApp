//
//  MyViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit
import FirebaseAuth

class MyViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    let databaseManager = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        configureUI()
    }
    
    func configureUI(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didDismissLoginNotification(_:)),
            name: NSNotification.Name("DismissLoginView"),
            object: nil
        )
        
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        
        logoutButton.clipsToBounds = true
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        
        databaseManager.getSelectBook{
            result in
            
        }
        
        setUserInfo()
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
        nameLabel.text = user.displayName
        
        UIImage().loadImage(imageUrl: user.photoURL?.absoluteString){ image in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
        
        nameLabel.gestureRecognizers = nil
        
        self.logoutButton.isHidden = false
    }
    
    func setLogoutUI(){
        
        print("이용자 로그인 X")
        
        nameLabel.textColor = .gray
        nameLabel.text = "로그인하기"
        userImageView.image = nil
        
        if nameLabel.gestureRecognizers == nil {
            let loginGes = UITapGestureRecognizer(target: self
                                                  , action: #selector(loginButtonTapped))
            nameLabel.addGestureRecognizer(loginGes)
            nameLabel.isUserInteractionEnabled = true
        }
        
        self.logoutButton.isHidden = true
    }
}
