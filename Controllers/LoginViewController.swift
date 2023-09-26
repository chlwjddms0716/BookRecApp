//
//  LoginViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/25.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    let databaseManager = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - 화면 전환 시 알림 보내기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("DismissLoginView"), object: nil, userInfo: nil)
    }
    
    // MARK: - 버튼 설정
    func configureUI(){
        
        googleLoginButton.clipsToBounds = true
        googleLoginButton.layer.cornerRadius = googleLoginButton.frame.height / 4
      
        appleLoginButton.clipsToBounds = true
        appleLoginButton.layer.cornerRadius = appleLoginButton.frame.height / 4
    }

    // MARK: - 구글 로그인 버튼 클릭
    @IBAction func googleLoginButtonTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let user = result?.user,
               let idToken = user.idToken?.tokenString {
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                
                // 사용자 정보 등록
                Auth.auth().signIn(with: credential){  result, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let resultData = result {
                        
                        print("이용자 등록 완료 : \(resultData.user.displayName)")
                        self.databaseManager.createUser(user: resultData.user)
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

