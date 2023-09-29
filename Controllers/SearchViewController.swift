//
//  SearchViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var keywordRemoveButton: UIButton!
    @IBOutlet weak var recKeywordCollectionView: UICollectionView!
    
    private let searchController = UISearchController(searchResultsController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchBookViewController") as! SearchBookViewController)
    
   private let flowLayout = UICollectionViewFlowLayout()
    
   private var searchHistory: [SearchHistory] = []
   private var keywordList: [Keyword] = []
    
   private let databaseManager = DatabaseManager.shared
  private  let networkManager = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        setupDatas()
        configureUI()
        setupKeywordDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
       
        setupDatas()
    }
    
    func setupKeywordDatas(){
        networkManager.fetchKeyword { result in
            switch result {
            case .success(let keywordData) :
                self.keywordList = keywordData
                DispatchQueue.main.async {
                    self.recKeywordCollectionView.reloadData()
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    func setupDatas(){
        
        databaseManager.getSearchHistory { searchData in
            if let searchHistory = searchData {
                self.searchHistory = searchHistory
                
                DispatchQueue.main.async {
                    self.keywordCollectionView.reloadData()
                    self.showKeywordView()
                }
            }
            else{
                self.hideKeywordView()
            }
        }
    }
    
    func setupCollectionView(){
        keywordCollectionView.dataSource = self
        keywordCollectionView.delegate = self
        
        keywordCollectionView.register(UINib(nibName: Cell.keywordCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Cell.keywordCellIdentifier)
        keywordCollectionView.showsHorizontalScrollIndicator = false
        
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
       layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        recKeywordCollectionView.dataSource = self
        recKeywordCollectionView.collectionViewLayout = layout
    }
    
    func setupSearchBar(){
        navigationItem.searchController = searchController
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "도서를 검색해보세요."
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.tintColor = UIColor(hexCode: Color.mainColor)
    }
    
    func configureUI(){
        keywordRemoveButton.clipsToBounds = true
        keywordRemoveButton.layer.cornerRadius = keywordRemoveButton.frame.height / 2
        keywordRemoveButton.backgroundColor = UIColor(hexCode: Color.grayColor)
    }
    
    func hideKeywordView(){
        
        DispatchQueue.main.async {
            if let heightConstraint = self.searchView.constraints.first(where: { $0.firstAttribute == .height }) {

                heightConstraint.constant = CGFloat(0)
                
                self.searchView.setNeedsUpdateConstraints()
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func showKeywordView(){
        DispatchQueue.main.async {
            if let heightConstraint = self.searchView.constraints.first(where: { $0.firstAttribute == .height }) {
                
                if heightConstraint.constant == 0 {

                    heightConstraint.constant = CGFloat(80)
                    
                    self.searchView.setNeedsUpdateConstraints()
                    
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction func keywordRemoveButtonTapped(_ sender: UIButton) {
        databaseManager.removeAllKeyword()
        
        searchHistory = []
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
            
            self.hideKeywordView()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


// MARK: - 서치바 Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let vc = searchController.searchResultsController as! SearchBookViewController
        vc.keyword = searchBar.text
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let vc = searchController.searchResultsController as! SearchBookViewController
        vc.keyword = ""
        
        setupDatas()
    }
}


extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == keywordCollectionView{
            return searchHistory.count
        }
        else{
            return keywordList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == keywordCollectionView {
            guard let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.keywordCellIdentifier, for: indexPath) as? KeywordCell else { return UICollectionViewCell() }
            
            cell.searchItem = searchHistory[indexPath.row]
            cell.removeButtonPressed = { [weak self] (searchData) in
                self!.databaseManager.removeByKeyword(searhData: searchData!) {
                    
                    self!.searchHistory.removeAll(where: {$0.timestamp == searchData!.timestamp})
                    DispatchQueue.main.async {
                        self!.keywordCollectionView.reloadData()
                        
                        if self!.searchHistory.count == 0 {
                            self!.hideKeywordView()
                        }
                    }
                }
            }
            
            return cell
        }
        else
        {
            guard let cell = recKeywordCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.recKeywordCellIdentifier, for: indexPath) as? RecKeywordCell else { return UICollectionViewCell() }
            
            cell.keywordLabel.text = keywordList[indexPath.row].word
            cell.keywordPressed = { [weak self] (keyword) in
                
                let vc = self!.searchController.searchResultsController as! SearchBookViewController
                self!.searchController.searchBar.text = keyword
                vc.keyword = keyword
                
                self!.searchController.searchBar.becomeFirstResponder()
                self!.searchController.searchBar.resignFirstResponder()
            }
            
            return cell
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellWidth: CGFloat = 150
        guard let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.keywordCellIdentifier, for: indexPath) as? KeywordCell else { return
            CGSize()}
        
        cell.keywordLabel.sizeToFit()
        cellWidth = cell.keywordLabel.frame.width + 20
        return CGSize(width: cellWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(-10)
    }
}
