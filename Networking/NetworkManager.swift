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
    typealias KeywordNetworkCompletion = (Result<[Keyword], NetworkError>) -> (Void)
    
    // MARK: - 메인화면에 표시할 대출 인기 도서
    func fetchBook(completion: @escaping NetworkCompletion) {
        
        let url = "\(BookApi.allBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)"
        print(url)
        getPopularBookList(url) { result in
            completion(result)
        }
    }
    
    // MARK: - 도서 검색
    func fetchSearchBook(keyword: String, completion: @escaping NetworkCompletion){
        
        let url = "\(BookApi.searchBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)&keyword=\(keyword)"
        print(url)
        getPopularBookList(url) { result in
            completion(result)
        }
    }
    
    // MARK: - 도서 상세설명
    func fetchBookDescription(isbn: String, completion: @escaping BookDescriptionNetworkCompletion ){
        
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
    func fetchMyBookList(bookList: [SelectBook], completion: @escaping ([Book]) -> (Void) ){
        
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
    
    // MARK: - 검색화면 이달의 키워드
    func fetchKeyword(completion: @escaping KeywordNetworkCompletion) {
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"

        let formattedDate = dateFormatter.string(from: currentDate)
        
        let url = "\(BookApi.monthlyKeywordURL)&\(BookApi.apiKeyParam)&month="
        
        getMonthlyKeyword("\(url)\(formattedDate)", completion: { result in
            print(url)
            switch result {
            case .success(let keywordList) :
                completion(.success(keywordList))
            case .failure(let error) :
                if error == NetworkError.parseError {
                    
                    guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else {
                        completion(result)
                        return
                    }
                    let preFormattedDate = dateFormatter.string(from: previousMonth)

                    getMonthlyKeyword("\(url)\(preFormattedDate)") { result in
                        print(url)
                        completion(result)
                        return
                    }
                }
                
                completion(result)
            }
        })
    }
    
    // MARK: - 카테고리 클릭
    func fetchCategoryBookList(category: Category, completion: @escaping NetworkCompletion) {
        
        let url = "\(BookApi.allBookURL)&\(BookApi.apiKeyParam)&\(BookApi.sizeParam)&dtl_kdc=\(category.code)"
        print(url)
        getPopularBookList(url) { result in
            completion(result)
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
    
    // MARK: - 도서관정보나루 : 인기대출도서 조회, 도서 키워드 검색
   private func getMonthlyKeyword(_ searchUrl: String, completion: @escaping KeywordNetworkCompletion ){
        
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
            
            if let keywordData = parseJSONToKeyword(safeData){
                completion(.success(keywordData))
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
           
            let detailBook: Book? = bookData.response.detail.first?.book
            
            return detailBook
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - 이달의 키워드 Json형식으로 변환
    private func parseJSONToKeyword(_ keywordData: Data) -> [Keyword]? {
        
        do {
            let keywordData = try JSONDecoder().decode(KeywordData.self, from: keywordData)
           
            var keywordArray: [Keyword] = []
            
            for item in keywordData.response.keywords{
                if let keyword = item.keyword {
                    keywordArray.insert(keyword, at: keywordArray.count)
                }
            }
           
            if keywordArray.count > 10 {
                keywordArray = Array(keywordArray[0..<11])
            }
            
            return keywordArray
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

