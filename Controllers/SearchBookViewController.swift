//
//  SearchBookViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/26.
//

import UIKit

class SearchBookViewController: ExtensionVC {
    
    weak var sv: UIView!
    
    @IBOutlet weak var bookTableView: UITableView!
    
   private let networkManager = NetworkManager.shared
   private let databaseManager = DatabaseManager.shared
    
    var keyword: String? {
        didSet{
            setupDatas()
        }
    }
    
    var category: Category? {
        didSet{
            setupCategoryDatas()
        }
    }
    
    var mainBookList: [Book]? = []
    
   private var bookArray: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let mainBookList = mainBookList else { return }
        if mainBookList.count > 0 {
            setupMainBookDatas()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainBookList = []
    }
    
    func showIndicator(){
        DispatchQueue.main.async {
            self.sv = UIViewController.displaySpinner(onView: self.view)
        }
    }
    
    func hideIndicator(){
        DispatchQueue.main.async {
            self.sv?.removeFromSuperview()
        }
    }
    
    func setupMainBookDatas(){
        hideIndicator()
        guard let mainBookList = mainBookList else { return }
        bookArray = mainBookList
        
        DispatchQueue.main.async {
            self.bookTableView.reloadData()
        }
    }
    
    func setupTableView(){
        bookTableView.delegate = self
        bookTableView.dataSource = self
        bookTableView.separatorStyle = .none
        
        bookTableView.backgroundColor = UIColor(hexCode: Color.grayColor)
        bookTableView.showsVerticalScrollIndicator = false
    }
    
    func setupCategoryDatas(){
        guard let category = category else { return }
        
        showIndicator()
        
        
        networkManager.fetchCategoryBookList(category: category) { result in

            switch result {
            case .success(let bookData) :
                self.bookArray = bookData
                DispatchQueue.main.async {
                    self.bookTableView.reloadData()
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
            
            self.hideIndicator()
        }
    }
    
    func setupDatas(){
        
        guard let keyword = keyword else { return }
        
        if keyword == "" {
            self.bookArray = []
            DispatchQueue.main.async {
                self.bookTableView.reloadData()
            }
            return
        }
        
        showIndicator()
        databaseManager.insertSearchKeyword(keyword: keyword)
        
        networkManager.fetchSearchBook (keyword: keyword){ result in
            switch result{
            case .success(let bookData):
                self.bookArray = bookData

                DispatchQueue.main.async {
                    self.bookTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            self.hideIndicator()
        }
    }
}


// MARK: - 테이블뷰 DataSource
extension SearchBookViewController: UITableViewDataSource{
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
extension SearchBookViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        vc.book = bookArray[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
  
}
