//
//  Book.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import Foundation


// MARK: - 인기도서 stuct
struct ResponseData: Codable {
    let response: Response
}

struct Response: Codable {
    let resultNum: Int?
    let docs: [BookData]
}

struct BookData: Codable {
    let doc: Book?
}

// MARK: - 도서 상세정보 struct
struct DetailResponseData: Codable {
    let response: DetailResponse
}

struct DetailResponse: Codable {
    let book: Book?
}

// MARK: - DocDoc
struct Book: Codable {
    let ranking, title, authors, publisher: String?
    let isbn: String?
    let bookImageURL: String?
    let description: String?
    var timestamp: Int?
    let publicationYear: String?
    let classNo: String?
    let loanCnt: Int?
    
    enum CodingKeys: String, CodingKey {
        case ranking, authors, publisher, bookImageURL
        case title = "bookname"
        case isbn = "isbn13"
        case description
        case publicationYear = "publication_year"
        case classNo = "class_no"
        case loanCnt
    }
}


