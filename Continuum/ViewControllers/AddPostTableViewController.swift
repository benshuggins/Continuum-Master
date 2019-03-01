//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Ben Huggins on 2/26/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    @IBOutlet weak var captionTextField: UITextField!
    
    
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captionTextField.text = nil
    }
   
  
   
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let photo = selectedImage,
            let caption = captionTextField.text else { return }
        PostController.shared.createPostWith(photo: photo, caption: caption) { (post) in
            //Leave empty for now
        }
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
      self.tabBarController?.selectedIndex = 0
    
    
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelectorVC" {
            let photoSelector = segue.destination as? PhotoSelectorViewController
            photoSelector?.delegate = self
        }
    }
 

}
extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
}


      
        
        
        
        



