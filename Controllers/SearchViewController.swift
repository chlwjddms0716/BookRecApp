//
//  SearchViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var bookTableView: UITableView!
    
    var keyword: String? {
        didSet{
            setupDatas(keyword: keyword)
        }
    }
    
    let networkManager = NetworkManager.shared
    
    var bookArray: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    func setupTableView(){
        bookTableView.delegate = self
        bookTableView.dataSource = self
    }
    
    func setupDatas(keyword: String?){
        
        guard let keyword = keyword else { return }
        
        if keyword == "" {
            self.bookArray = []
            DispatchQueue.main.async {
                self.bookTableView.reloadData()
            }
            return
        }
        
        networkManager.searchBook (keyword: keyword){ result in
            switch result{
            case .success(let bookData):
                self.bookArray = bookData

                DispatchQueue.main.async {
                    self.bookTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - 테이블뷰 DataSource
extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bookTableView.dequeueReusableCell(withIdentifier: Cell.searchBookCellIdentifier, for: indexPath) as! SearchCell
        
        cell.bookData = bookArray[indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - 테이블뷰 Delegate
extension SearchViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        vc.book = bookArray[indexPath.row]
        self.present(vc, animated: true)
    }
}
