//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Ben Huggins on 2/26/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var post: Post?{
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = post else {return}
        PostController.shared.fetchComments(for: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
    
        }
    }
    
    //MARK: - Methods
    func updateViews() {
        photoImageView.image = post?.photo
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return post?.comments.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timestamp.stringWith(dateStyle: .medium, timeStyle: .short)
        return cell
        }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentCommentAlertController()
        
        
    }
    
    func presentCommentAlertController() {
        let alertController = UIAlertController(title: "Add a Comment", message: "Add new Comment", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Your witty comment here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let commentAction = UIAlertAction(title: "Comment", style: .default) { (_) in
            guard let commentText = alertController.textFields?.first?.text,
                !commentText.isEmpty,
                let post = self.post else { return }
            PostController.shared.addComment(text: commentText, post: post, completion: { (comment) in
            })
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(commentAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
