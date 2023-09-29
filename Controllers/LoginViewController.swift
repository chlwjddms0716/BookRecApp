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
    
    
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
   private let databaseManager = DatabaseManager.shared
    
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
        googleLoginButton.layer.cornerRadius = RadiusNumber.buttonRadiusNum
        googleLoginButton.layer.borderColor = UIColor(hexCode: Color.grayColor).cgColor
        googleLoginButton.layer.borderWidth = 1
      
        closeButton.tintColor = UIColor(hexCode: Color.mainColor)
        
        emailTextField.clipsToBounds = true
        emailTextField.layer.cornerRadius = RadiusNumber.buttonRadiusNum
        
        pwTextField.clipsToBounds = true
        pwTextField.layer.cornerRadius = RadiusNumber.buttonRadiusNum
        
        emailLoginButton.clipsToBounds = true
        emailLoginButton.layer.cornerRadius = RadiusNumber.buttonRadiusNum
        emailLoginButton.backgroundColor = UIColor(hexCode: Color.mainColor)
        
        emailLoginButton.layer.shadowColor = UIColor.black.cgColor
        emailLoginButton.layer.masksToBounds = false
        emailLoginButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        emailLoginButton.layer.shadowRadius = 5
        emailLoginButton.layer.shadowOpacity = 0.3
        
        googleLoginButton.layer.shadowColor = UIColor.black.cgColor
        googleLoginButton.layer.masksToBounds = false
        googleLoginButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        googleLoginButton.layer.shadowRadius = 5
        googleLoginButton.layer.shadowOpacity = 0.1
        
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        emailTextField.layer.masksToBounds = false
        emailTextField.layer.shadowOffset = CGSize(width: 0, height: 3)
        emailTextField.layer.shadowRadius = 5
        emailTextField.layer.shadowOpacity = 0.1
        
        pwTextField.layer.shadowColor = UIColor.black.cgColor
        pwTextField.layer.masksToBounds = false
        pwTextField.layer.shadowOffset = CGSize(width: 0, height: 3)
        pwTextField.layer.shadowRadius = 5
        pwTextField.layer.shadowOpacity = 0.1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - 닫기 버튼 클릭
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - 이메일 로그인 버튼 클릭
    @IBAction func emailLoginButtonTapped(_ sender: UIButton) {
        
        if let email = emailTextField.text, let pw = pwTextField.text {
            Auth.auth().signIn(withEmail: email, password: pw) { (result, error) in
                if let error = error {
                    // 로그인 실패
                    print("로그인 실패: \(error.localizedDescription)")
                } else {
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let resultData = result {
                        
                        print("이용자 등록 완료 : \(String(describing: resultData.user.displayName))")
                        self.databaseManager.createUser(user: resultData.user)
                        self.dismiss(animated: true)
                    }
                }
            }
        }
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
                        
                        print("이용자 등록 완료 : \(String(describing: resultData.user.displayName))")
                        self.databaseManager.createUser(user: resultData.user)
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

