//
//  Book.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import Foundation

// MARK: - Welcome
struct ResponseData: Codable {
    let response: Response
}

// MARK: - Response
struct Response: Codable {
    let resultNum: Int?
    let docs: [BookData]
}

// MARK: - DocElement
struct BookData: Codable {
    let doc: Book?
}

// MARK: - DocDoc
struct Book: Codable {
    let ranking, title, authors, publisher: String?
    let isbn: String?
    let bookImageURL: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case ranking, authors, publisher, bookImageURL
        case title = "bookname"
        case isbn = "isbn13"
        case description
    }
}


