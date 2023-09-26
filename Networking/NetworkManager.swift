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
    typealias DetailBookNetworkCompletion = (Result<Book?, NetworkError>) -> (Void)
    
    // MARK: - 메인화면에 표시할 대출 인기 도서
    func fetchBook(completion: @escaping NetworkCompletion) {
        
        let url = "\(BookApi.allBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)"
        print(url)
        getPopularBookList(url) { result in
            completion(result)
        }
    }
    
    // MARK: - 도서 검색
    func searchBook(keyword: String, completion: @escaping NetworkCompletion){
        
        let url = "\(BookApi.searchBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)&keyword=\(keyword)"
        print(url)
        getPopularBookList(url) { result in
            completion(result)
        }
    }
    
    // MARK: - 도서 상세설명
    func getBookDescription(isbn: String, completion: @escaping BookDescriptionNetworkCompletion ){
        
        let url = "\(BookApi.searchBookDescriptionURL)&\(BookApi.apiKeyParam)&isbn13=\(isbn)"
        print(url)
        getDetailBook(url) {
            result in
            
            switch result {
            case .success(let book):
                if let bookData = book, let bookDescription = bookData.description{
                    completion(.success(bookDescription))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 서재에 담긴 도서 리스트
    func getMyBookList(bookList: [SelectBook], completion: @escaping ([Book]) -> (Void) ){
        
        var loadNum = 0
        var bookArray: [Book] = []
        for book in bookList {
            
            let url = "\(BookApi.searchBookDescriptionURL)&\(BookApi.apiKeyParam)&isbn13=\(book.isbn)"
            print(url)
           getDetailBook(url) {
                result in
                
                switch result {
                case .success(let bookData) :
                    if var safeBook = bookData {
                        safeBook.timestamp = book.timestamp
                        bookArray.append(safeBook)
                    }
                    break
                case .failure(_):
                    print(book.isbn + " 도서 가져오기 실패")
                }
                loadNum += 1
                
                if loadNum == bookList.count {
                    
                    let sortedSelectBooks = bookArray.sorted(by: { term1, term2 in
                        if let firstTime = term1.timestamp, let secondTime = term2.timestamp{
                           return firstTime > secondTime
                        }
                        else
                        {
                            return true
                        }
                    })
                    completion(sortedSelectBooks)
                    return
                }
            }
        }
    }

    
    // MARK: - 도서관정보나루 : 도서 상세 조회
    private func getDetailBook(_ searchUrl: String, completion: @escaping DetailBookNetworkCompletion ){
        
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
            
            if let bookData = parseJSONToDetailBook(safeData) {
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
    
    
    // MARK: - 도서관정보나루 : 인기대출도서 조회, 도서 키워드 검색
   private func getPopularBookList(_ searchUrl: String, completion: @escaping NetworkCompletion ){
        
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
    
    // MARK: - 인기대출도서조회 Json형식으로 변환
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
    
    // MARK: - 도서 상세 조회 Json형식으로 변환
    private func parseJSONToDetailBook(_ bookData: Data) -> Book? {
        
        do {
            let bookData = try JSONDecoder().decode(DetailResponseData.self, from: bookData)
           
            var detailBook: Book? = bookData.response.detail.first?.book
            
            return detailBook
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

