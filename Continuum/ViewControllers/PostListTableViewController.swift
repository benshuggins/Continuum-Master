//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Ben Huggins on 2/26/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var resultsArray: [Post] = []
    var isSearching = false
    var dataSource: [Post] {
        if isSearching{
            return resultsArray
        } else {
            return PostController.shared.posts
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        performFullSync(completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViews), name: PostController.shared.postsWereUpdatedNotification, object: nil)
    }
    
    @objc func reloadViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        let post = dataSource[indexPath.row] as? Post
        cell.post = post
        return cell
    }
    
    //MARK: - sync up phone when first launched
    func performFullSync(completion:((Bool) ->Void)?){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.shared.fetchPosts { (posts) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
                completion?(posts != nil)
            }
        }
    }
   

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailVC" {
            let destinationVC = segue.destination as! PostDetailTableViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let post = PostController.shared.posts[indexPath.row]
            destinationVC.post = post
        }
    }
}

extension PostListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = PostController.shared.posts.filter { $0.matches(searchTerm: searchText)}
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    
}
        
        
    



