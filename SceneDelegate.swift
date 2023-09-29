//
//  SceneDelegate.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 윈도우 객체와 연결된 루트뷰컨트롤러 가져오기
        
                if let tbc = self.window?.rootViewController as? UITabBarController {
                    
                    // 큰 이미지 자르기: 이미지가 tabBar보다 큰 경우 밖으로 튀어나옴
                    tbc.tabBar.clipsToBounds = true
                    
                    // 탭바 아이템
                    if let tbItems = tbc.tabBar.items {
                        tbItems[0].image = UIImage(systemName: "magnifyingglass")?.resized(to: CGSize(width: 25, height: 20), tintColor: UIColor(hexCode: "CCCCCC"))
                        tbItems[1].image = UIImage(systemName: "house")?.resized(to: CGSize(width: 25, height: 20), tintColor: UIColor(hexCode: "CCCCCC"))
                        tbItems[2].image = UIImage(systemName: "person")?.resized(to: CGSize(width: 25, height: 20), tintColor: UIColor(hexCode: "CCCCCC"))
                        
                        // 탭바 아이템의 타이틀 설정
                        for tbItem in tbItems {
                            tbItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .disabled)
                            tbItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexCode: Color.mainColor)], for: .selected)
                        }
                        
                        // proxy객체 사용 : for문으로 접근하지 않아도 가능
                        // 탭바 아이템에 일일이 할 필요 없이, 일괄적 적용
                        let tbItemProxy = UITabBarItem.appearance()
                        tbItemProxy.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
                    }
                    
                    tbc.tabBar.tintColor = UIColor(hexCode: Color.mainColor)
                    tbc.selectedIndex = 1
                }
                
                guard let _ = (scene as? UIWindowScene) else { return }
            }
    
    
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }




