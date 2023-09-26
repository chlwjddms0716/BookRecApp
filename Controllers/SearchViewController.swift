//
//  SearchViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var keywordRemoveButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchBookViewController") as! SearchBookViewController)
    
    let flowLayout = UICollectionViewFlowLayout()
    
    var searchHistory: [SearchHistory] = []
        
    let databaseManager = DatabaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupDatas()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupDatas()
    }
    
    func setupDatas(){
        
        searchHistory = []
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
        }
        
        databaseManager.getSearchHistory { searchData in
            if let searchHistory = searchData {
                self.searchHistory = searchHistory
                
                DispatchQueue.main.async {
                    self.keywordCollectionView.reloadData()
                   
                }
            }
        }
    }
    
    func setupTableView(){
        keywordCollectionView.dataSource = self
        keywordCollectionView.delegate = self

        keywordCollectionView.register(UINib(nibName: Cell.keywordCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Cell.keywordCellIdentifier)
    }
    
    func setupSearchBar(){
        navigationItem.searchController = searchController
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "도서를 검색해보세요."
    }
    
    func configureUI(){
        keywordRemoveButton.clipsToBounds = true
        keywordRemoveButton.layer.cornerRadius = keywordRemoveButton.frame.height / 2
    }
    
    @IBAction func keywordRemoveButtonTapped(_ sender: UIButton) {
        databaseManager.removeAllKeyword()
        
        searchHistory = []
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
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
        return searchHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.keywordCellIdentifier, for: indexPath) as? KeywordCell else { return UICollectionViewCell() }
        
        cell.searchItem = searchHistory[indexPath.row]
        cell.removeButtonPressed = { [weak self] (searchData) in
            self!.databaseManager.removeByKeyword(searhData: searchData!) {
                
                self!.searchHistory.removeAll(where: {$0.timestamp == searchData!.timestamp})
                DispatchQueue.main.async {
                    self!.keywordCollectionView.reloadData()
                }
            }
        }
        
        return cell
    }
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#function)
        guard let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.keywordCellIdentifier, for: indexPath) as? KeywordCell else { return
        CGSize()}
      
                // ✅ sizeToFit() : 텍스트에 맞게 사이즈가 조절
                cell.keywordLabel.sizeToFit()

                // ✅ cellWidth = 글자수에 맞는 UILabel 의 width + 20(여백)
                let cellWidth = cell.keywordLabel.frame.width + 20

                return CGSize(width: cellWidth, height: 30)
    }
}
