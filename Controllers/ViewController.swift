//
//  ViewController.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicatorVIew: UIActivityIndicatorView!
    
    @IBOutlet weak var bookTableView: UITableView!
    
    var bookArray: [Book] = []
    
    let networkManager = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDatas()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookTableView.reloadData()
    }
    
    func showIndicator(){
        loadingIndicatorVIew.isHidden = false
        loadingIndicatorVIew.startAnimating()
    }
    
    func hideIndicator(){
        loadingIndicatorVIew.isHidden = true
        loadingIndicatorVIew.stopAnimating()
    }

    func setupTableView(){
        bookTableView.delegate = self
        bookTableView.dataSource = self
    }
    
    func setupDatas(){
        showIndicator()
        
        networkManager.fetchBook { result in
            
            switch result {
            case .success(let bookArray):
                self.bookArray = bookArray
                
                DispatchQueue.main.async{
                    self.bookTableView.reloadData()
                    self.hideIndicator()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


// MARK: - 테이블뷰 DataSource
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bookTableView.dequeueReusableCell(withIdentifier: Cell.bookCellIdentifier, for: indexPath) as! bookCell
        
        cell.bookData = bookArray[indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - 테이블뷰 Delegate
extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        vc.book = bookArray[indexPath.row]
        self.present(vc, animated: true)
    }
}

