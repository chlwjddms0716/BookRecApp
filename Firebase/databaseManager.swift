//
//  DatabaseManager.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

public enum DatabaseError: Error {
    case existBookError
    case updateFailError
}

public struct DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    
    private let ref = Database.database().reference()
    
    // MARK: - 이용자 추가
    func createUser(user: User){
        let userItemRef = ref.child("User").child(user.uid)
        let dataToSave: [String: Any] = [
            "selectBook" : "" ,
            "searchHistory" : ""
        ]
        
        getAllUsers { userData in
            if let userList = userData {
                if let userID = Auth.auth().currentUser?.uid {
                    if !userList.contains(userID){
                        userItemRef.setValue(dataToSave)
                        print("이용자 추가 완료")
                    }
                    else{
                        print("이미 있는 이용자")
                    }
                }
            }
            else{
                userItemRef.setValue(dataToSave)
                print("이용자 추가")
            }
        }
    }
    
    // MARK: - 전체 이용자 가져오기
    func getAllUsers(completion: @escaping ([String]?) -> (Void)){
        ref.child("User").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
           
            let userList: [String]  = Array(value.keys)
            completion(userList)
            
        }) { error in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    // MARK: - 서재에 담긴 도서 전부 가져오기
    func getSelectBook(completion: @escaping ([SelectBook]?) -> (Void)){
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("User").child(userID).child("selectBook").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let selectData = snapshot.value as? [String : Any] else {
                completion(nil)
                return
            }
            
            do{
                let data = try? JSONSerialization.data(withJSONObject: Array(selectData.values), options: [])
                
                let decoder = JSONDecoder()
                if let safeData = data {
                    let selectBooks = try? decoder.decode([SelectBook].self, from: safeData)
                    
                    completion(selectBooks)
                    return
                }
                
                completion(nil)
            
            }catch{
                completion(nil)
            }
        }) { error in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    // MARK: - 서재에 도서 추가
    func insertSelectBook(bookIsbn: String, completion: @escaping (Result<Bool, DatabaseError>) -> (Void)) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        let data: [String : Any] = [
            "isbn" : bookIsbn,
            "timestamp" : Date().timeIntervalSince1970.rounded()
        ]
        
        getSelectBook{ bookList in
            
            if let bookListData = bookList {
                for book in bookListData {
                    if  book.isbn == bookIsbn {
                        completion(.failure(.existBookError))
                        return
                    }
                }
            }
                
            ref.child("User").child(user.uid).child("selectBook").childByAutoId().updateChildValues(data) { (error, reference) in
                
                if let error = error {
                    completion(.failure(.updateFailError))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    // MARK: - 검색한 키워드 저장하기
    func insertSearchKeyword(keyword: String) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        let data: [String : Any] = [
            "term" : keyword,
            "timestamp" : Date().timeIntervalSince1970.rounded()
        ]
        
        
        getSearchHistory { result in
            
            if let resultData = result {
                for keywordData in resultData {
                    if  keywordData.term == keyword {
                        return
                    }
                }
            }
            
            ref.child("User").child(user.uid).child("searchHistory").childByAutoId().updateChildValues(data) { (error, reference) in
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                   print("Keyword Update Success")
                }
            }
        }
    }
    
    // MARK: - 검색한 키워드 가져오기
    func getSearchHistory(completion: @escaping ([SearchHistory]?) -> (Void)){
        
        guard let userID = Auth.auth().currentUser?.uid else { 
            completion(nil)
            return }
        
        ref.child("User").child(userID).child("searchHistory").observeSingleEvent(of: .value, with: { snapshot in
           
            guard let searchData = snapshot.value as? [String : Any] else {
                completion(nil)
                return
            }
            
            do{
                let data = try? JSONSerialization.data(withJSONObject: Array(searchData.values), options: [])
               
                let decoder = JSONDecoder()
                if let safeData = data {
                    let searchHistory = try? decoder.decode([SearchHistory].self, from: safeData)
                   
                    if let safeHistory = searchHistory {
                        let sortedSearchHistory = safeHistory.sorted(by: { term1, term2 in
                            return term1.timestamp > term2.timestamp
                        })
                        completion(sortedSearchHistory)
                        return
                    }
                    
                    completion(nil)
                }
                
                completion(nil)
            }catch{
            
                completion(nil)
            }
        }) { error in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    // MARK: - 키워드 삭제
    func removeByKeyword(searhData: SearchHistory, completion: @escaping () -> (Void)){
        guard let user = Auth.auth().currentUser else { return }
        
        ref.child("User").child(user.uid).child("searchHistory").queryOrdered(byChild: "timestamp").queryStarting(atValue: searhData.timestamp).queryEnding(atValue: "\(String(describing: searhData.timestamp))\\uf8ff").observeSingleEvent(of: .value) { snapshot in
            
            guard let safeData = snapshot.value as? [String : Any], let key = safeData.keys.first else { return }
            
            ref.child("User").child(user.uid).child("searchHistory").child(key).removeValue { Error, reference in
                 completion()
            }
        }
    }
    
    // MARK: - 키워드 전체 삭제
    func removeAllKeyword(){
        guard let user = Auth.auth().currentUser else { return }
        
        ref.child("User").child(user.uid).child("searchHistory").removeValue { error, _ in
            if let error = error {
        print("데이터 삭제 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("데이터가 성공적으로 삭제되었습니다.")
            }
        }
    }
    
    // MARK: - 즐겨찾기 도서 삭제
    func removeMyBook(bookData: Book, completion: @escaping () -> (Void)){
        guard let user = Auth.auth().currentUser else { return }
        
        ref.child("User").child(user.uid).child("selectBook").queryOrdered(byChild: "isbn").queryStarting(atValue: bookData.isbn).queryEnding(atValue: "\(String(describing: bookData.isbn))\\uf8ff").observeSingleEvent(of: .value) { snapshot in
            
            guard let safeData = snapshot.value as? [String : Any], let key = safeData.keys.first else { return }
            
            ref.child("User").child(user.uid).child("selectBook").child(key).removeValue { Error, reference in
                 completion()
            }
        }
    }
}


