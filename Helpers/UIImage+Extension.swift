//
//  UIImage+Extension.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

extension UIImage {
    
    func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //    Or if you need a thinner border :
        //    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func resized(to size: CGSize, tintColor: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            // 적용할 tint 색상 설정
            tintColor.setFill()
            // 렌더링 모드 변경 후 이미지 그리기
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func loadImage(imageUrl: String?, isUser: Bool = false, completion: @escaping (UIImage) -> Void ) {
        
        if let imgUrl = imageUrl, let url = URL(string: imgUrl){
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        completion(image)
                        return
                    }
                }
            }
        }
        else{
            if isUser {
                completion(UIImage(systemName: "person.circle")!.withTintColor(UIColor(hexCode: Color.mainColor), renderingMode: .alwaysOriginal))
            }
            else
            {
                completion(UIImage(named: "noImage")!)
            }
        }
    }
}
