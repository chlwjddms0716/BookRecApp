//
//  ViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit
import AlignedCollectionViewFlowLayout

class ViewController: UIViewController {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var bookCollectionView: UICollectionView!

    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var loadingIndicatorVIew: UIActivityIndicatorView!
    
    var bookArray: [Book] = []
    
    let networkManager = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupCollectionView()
       setupTabbar()
       setupDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bookCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        categoryCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        bookCollectionView.reloadData()
    }
    
    func configureUI(){
        searchBarView.clipsToBounds = true
        searchBarView.layer.cornerRadius = 10
        searchBarView.backgroundColor = UIColor(hexCode: Color.lightGrayColor)
        searchBarView.layer.borderWidth = 1
        searchBarView.layer.borderColor = UIColor(hexCode: Color.grayColor).cgColor
        
        let searchBarclick = UITapGestureRecognizer(target: self
                                              , action: #selector(searchBarTapped))
        searchBarView.addGestureRecognizer(searchBarclick)
        searchBarView.isUserInteractionEnabled = true
        
        let backBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = UIColor(hexCode: Color.mainColor)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func setupTabbar(){
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.layer.shadowColor = UIColor.lightGray.cgColor
            tabBar.layer.shadowOpacity = 0.3
            tabBar.layer.shadowOffset = CGSize.zero
            tabBar.layer.shadowRadius = 5
            tabBar.layer.borderColor = UIColor.clear.cgColor
            tabBar.layer.borderWidth = 0
            tabBar.clipsToBounds = false
            tabBar.backgroundColor = UIColor.white
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
        }
    }
    
    func showIndicator(){
        loadingIndicatorVIew.isHidden = false
        loadingIndicatorVIew.startAnimating()
    }
    
    func hideIndicator(){
        loadingIndicatorVIew.isHidden = true
        loadingIndicatorVIew.stopAnimating()
    }

    
    func setupCollectionView(){

        bookCollectionView.dataSource = self
        bookCollectionView.delegate = self
        bookCollectionView.register(UINib(nibName: Cell.mainBookCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Cell.mainBookCellIdentifier)
        bookCollectionView.showsHorizontalScrollIndicator = false
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: Cell.categoryCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Cell.categoryCellIdentifier)
        categoryCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func setupDatas(){
        showIndicator()
        
        networkManager.fetchBook { result in
            
            switch result {
            case .success(let bookArray):
                self.bookArray = bookArray
                
                DispatchQueue.main.async{
                    self.bookCollectionView.reloadData()
                    self.hideIndicator()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func searchBarTapped(){
      
        self.tabBarController?.selectedIndex = 0
    }
    
    
    @IBAction func seeMoreTapped(_ sender: UIButton) {
        if bookArray.count > 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SearchBookViewController") as! SearchBookViewController
            vc.mainBookList = bookArray
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// MARK: - 테이블뷰 DataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bookCollectionView {
            return bookArray.count > 10 ? 10 : bookArray.count
        }
        else{
            return CategoryManager.categoryArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bookCollectionView {
            guard  let cell = bookCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.mainBookCellIdentifier, for: indexPath) as? MainBookCell else { return UICollectionViewCell()}
            cell.bookData = bookArray[indexPath.row]
            
            return cell
        }
        else {
            guard let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.categoryCellIdentifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell()}
            
            cell.category = CategoryManager.categoryArray[indexPath.row]
            
            return cell
        }
    }

    
}

// MARK: - 테이블뷰 Delegate
extension ViewController: UICollectionViewDelegateFlowLayout , UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bookCollectionView {
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.book = bookArray[indexPath.row]
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        else
        {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SearchBookViewController") as! SearchBookViewController
            vc.category = CategoryManager.categoryArray[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == categoryCollectionView {
            return CGFloat(-30)
        }
        else{
            return CGFloat(-20)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            return CGSize(width: CategoryCVCell.width , height: CategoryCVCell.height)
        }
        else {
           
            return CGSize(width: MainCVCell.width, height: MainCVCell.height)
        }
    }
}

