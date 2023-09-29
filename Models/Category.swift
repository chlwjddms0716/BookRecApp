//
//  Category.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/27.
//

import UIKit

struct Category {
    
    let word: String
    let code: String
    var icon: UIImage?
    
}

public struct CategoryManager {
    
    private init() {}
    
    static let categoryArray: [Category] = [
    
        Category(word: "언론", code: "07", icon: UIImage(named: "news")),
        Category(word: "철학", code: "10", icon: UIImage(named: "philosophy")),
        Category(word: "심리", code: "18", icon: UIImage(named: "psychology")),
        Category(word: "논리", code: "17", icon: UIImage(named: "logic")),
        Category(word: "종교", code: "20", icon: UIImage(named: "religion")),
        Category(word: "과학", code: "40", icon: UIImage(named: "science")),
        Category(word: "경제", code: "32", icon: UIImage(named: "economy")),
        Category(word: "정치", code: "34", icon: UIImage(named: "political")),
        Category(word: "법학", code: "36", icon: UIImage(named: "law")),
        Category(word: "수학", code: "41", icon: UIImage(named: "mathematics")),
        Category(word: "화학", code: "43", icon: UIImage(named: "chemistry")),
        Category(word: "천문", code: "44", icon: UIImage(named: "astrology")),
        Category(word: "공학", code: "53", icon: UIImage(named: "engineering")),
        Category(word: "예술", code: "60", icon: UIImage(named: "art")),
        Category(word: "언어", code: "70", icon: UIImage(named: "language")),
        Category(word: "역사", code: "90", icon: UIImage(named: "history")),
    ]
}
