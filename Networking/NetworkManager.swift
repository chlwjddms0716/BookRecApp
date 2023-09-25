//
//  NetworkManager.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import Foundation

public enum NetworkError: Error{
    case networkingError
    case dataError
    case parseError
}

public struct NetworkManager{
    
    static let shared = NetworkManager()
    private init(){}
    
    
    
    typealias NetworkCompletion = (Result<[Book], NetworkError>) -> (Void)
    typealias BookDescriptionNetworkCompletion = (Result<String, NetworkError>) -> (Void)
    
    func fetchBook(completion: @escaping NetworkCompletion) {
        
        let url = "\(BookApi.allBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)"
        print(url)
        getBook(url) { result in
            completion(result)
        }
    }
    
    func searchBook(keyword: String, completion: @escaping NetworkCompletion){
        
        let url = "\(BookApi.searchBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)&keyword=\(keyword)"
        print(url)
        getBook(url) { result in
            completion(result)
        }
    }
    
    func getBookDescription(isbn: String, completion: @escaping BookDescriptionNetworkCompletion ){
        
        let url = "\(BookApi.searchBookDescriptionURL)&\(BookApi.apiKeyParam)&isbn13=\(isbn)"
        print(url)
        getDescription(url) {
            result in
            completion(result)
        }
    }
    
    private func getDescription(_ searchUrl: String, completion: @escaping BookDescriptionNetworkCompletion ){
        
        guard let url = URL(string: searchUrl) else { return }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ (data, response, error) in
            
            if error != nil{
                completion(.failure(.networkingError))
                return
            }
            
            guard let safeData = data else {
                completion(.failure(.dataError))
                return
            }
            
            if let bookDescription = parseJSON2(safeData){
                completion(.success(bookDescription))
                return
            }
            else
            {
                completion(.failure(.parseError))
                return
            }
        }.resume()
        
    }
    
   private func parseJSON2(_ bookData: Data) -> String? {
        
        do {
            if let json = try JSONSerialization.jsonObject(with: bookData) as? [String: Any] {
                if let boxOfficeResult = json["response"] as? [String: Any] {
                    if let dailyBoxOfficeList = boxOfficeResult["detail"] as? [[String: Any]] {
                        for item in dailyBoxOfficeList {
                            if let bookData = item["book"] as? [String: Any] {
                                let descripData = bookData["description"] as! String?
                                
                                return descripData
                            }
                        }
                    }
                }
            }
            
            return nil
            
        } catch {
            
            return nil
        }
        
    }
    
    
   private func getBook(_ searchUrl: String, completion: @escaping NetworkCompletion ){
        
        guard let url = URL(string: searchUrl) else { return }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ (data, response, error) in
            
            if error != nil{
                completion(.failure(.networkingError))
                return
            }
            
            guard let safeData = data else {
                completion(.failure(.dataError))
                return
            }
            
            if let bookData = parseJSON(safeData){
                completion(.success(bookData))
                return
            }
            else
            {
                completion(.failure(.parseError))
                return
            }
        }.resume()
        
    }
    
   private func parseJSON(_ bookData: Data) -> [Book]? {
        
        do {
            let bookData = try JSONDecoder().decode(ResponseData.self, from: bookData)
            
            var bookArray: [Book] = []
            
            for item in  bookData.response.docs{
                if let book = item.doc {
                    bookArray.insert(book, at: bookArray.count)
                }
            }
            
            return bookArray
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}

