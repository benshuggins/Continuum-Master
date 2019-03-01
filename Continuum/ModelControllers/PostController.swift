//
//  PostController.swift
//  Continuum
//
//  Created by Ben Huggins on 2/26/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostController {
    
  static let shared = PostController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    let postsWereUpdatedNotification = Notification.Name("Posts were updated")
    
    var posts: [Post] = [] {
        didSet {
            
            NotificationCenter.default.post(name: postsWereUpdatedNotification, object: nil)
        }
        
        
    }
    
    
    
    
    func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        
        
         let record = CKRecord(comment: comment)
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                
                print("\(error.localizedDescription):  \(error)")
                completion(nil)
                return
            }
            
            guard let record = record else { completion(nil); return}
            let comment = Comment(ckRecord: record, post: post)
            self.incrementCommentCount(for: post, completion: nil)
            
            completion(comment)
        }
    }
    
    
    //MARK: - saving to iCloud
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(photo: photo, caption: caption)
        posts.append(post)

        // here we are turning a post into a record to save the record
        guard let record = CKRecord(post: post) else {return}
        publicDB.save(record) { (record, error) in
            if let error = error{
                print("\(error.localizedDescription): \(error)")
                completion(nil)
                return
            }
            guard let record = record,
                let post = Post(ckRecord: record)  else { completion(nil) ; return }
            completion(post)
        }
    }
    
    //MARK: - fetching
    // fetching requires no params...
    func fetchPosts(completion: @escaping (([Post]?) -> Void)) {
        //work backwards first we need a predicate, then query and then we place in our perform function
        let predicate = NSPredicate(value: true) //this gets all of the posts back
        // build query with the key that associates with the posts record ID !!!!!
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
    
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("error fetching the records from database \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let records = records else {completion(nil); return}
            // get the post out of the ckrecord and into an array with compact map
            
            
            
            let posts = records.compactMap{ Post(ckRecord: $0)} //<-- Call our failable convenience init() and turn the record back into a model to pop our TableView
            // assign posts we got back to our SOT
            self.posts = posts
       
            
        }
    }
        func fetchComments(for post: Post, completion: @escaping ([Comment]?) -> Void) {
            let findPostRef = post.recordID // <-- how does this get the correct recordID
            // all comments that have this reference will be pulled
            let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, findPostRef)
            
            let commentsPulled = post.comments.compactMap{($0)}
            
            let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentsPulled)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
            
            let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("Error fetching comments from cloudKit \(#function) \(error) \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let records = records else { completion(nil); return }
                let comments = records.compactMap{ Comment(ckRecord: $0, post: post) }
                post.comments.append(contentsOf: comments)
                completion(comments)
            }
        }
        
        //MARK: - Update Methods
        func incrementCommentCount(for post: Post, completion: ((Bool)-> Void)?){
            //increase comment by 1
            post.commentCount += 1
            //Initialize the class that will modify a post's CKRecord in CloudKit
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)!], recordIDsToDelete: nil)  //<--- bang operator !!!!
            //Only update changed properties
            modifyOperation.savePolicy = .changedKeys
            
            
            modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
                if let error = error{
                    print("\(error.localizedDescription) \(error) in function: \(#function)")
                    completion?(false)
                    return
                }else {
                    completion?(true)
                }
            }
            //Add the operation to the public database
            CKContainer.default().publicCloudDatabase.add(modifyOperation)
        
            
        }

func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
    let predicate = NSPredicate(value: true)
     let subscription = CKQuerySubscription(recordType: "Post", predicate: predicate, subscriptionID: "All Posts", options: .firesOnRecordCreation)
    let notifcationInfo = CKSubscription.NotificationInfo()
    notifcationInfo.alertBody = "New post added"
   
    notifcationInfo.shouldBadge = true
    notifcationInfo.shouldSendContentAvailable = true
    subscription.notificationInfo = notifcationInfo
    //Save
    CKContainer.default().publicCloudDatabase.save(subscription) { (subscription, error) in
        if let error = error {
            print("There was an error \(error)  ; \(error.localizedDescription)  💩")
            completion?(false, error)
        }else {
            completion?(true, nil)
        }
    }
}
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        let postRecordID = post.recordID
       
        let predicate = NSPredicate(format: "%K = %@", CommentConstants.postReferenceKey, postRecordID)
       
        let subscription = CKQuerySubscription(recordType: "Comment", predicate: predicate, subscriptionID: post.recordID.recordName, options: .firesOnRecordCreation)
       
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "A new comment was added a a post you follow!"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = nil
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (_, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  ")
                completion?(false, error)
            }else{
                completion?(true, nil)
            }
        }
    }

    
    
    
    
}
        
        
        

    

    
    

