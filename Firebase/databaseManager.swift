//
//  DatabaseManager.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

public struct DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    
    private let ref = Database.database().reference()
    
    func createUser(user: User){
        
        getAllUsers { userData in
            if let userList = userData {
                print("1")
                if let userID = Auth.auth().currentUser?.uid {
                    print("2")
                    if !userList.contains(userID){
                        print("3")
                        let userItemRef = ref.child("User")
                        let values: [String? : Any] = [ user.uid : ["selectBook" : [] ] ]
                        userItemRef.setValue(values)
                        print("이용자 추가")
                    }
                    else{
                        print("이미 있는 이용자")
                    }
                }
            }
        }
    }
    
    func getAllUsers(completion: @escaping ([String]?) -> (Void)){
        
        ref.child("User").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                
                var userList: [String]  = Array(value.keys)
                print("userList 가져옴")
                print(userList)
                completion(userList)
            }
        }) { error in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    
    func getSelectBook(completion: @escaping ([String]?) -> (Void)){
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("User").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
              
                print(value)
                
//                var selectBooks: [String] = Array(value.values)
//                print(selectBooks)
               //completion(selectBooks)
            }
        }) { error in
            print(error.localizedDescription)
            completion(nil)
        }
        
    }
}
