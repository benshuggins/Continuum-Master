//
//  Comment.swift
//  Continuum
//
//  Created by Ben Huggins on 2/26/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//
import CloudKit
import Foundation

class Comment {
    let text: String
    let timestamp: Date
    weak var post: Post?
    let recordID: CKRecord.ID  // this is the record id used to save comments to icloud 
    
    
    // creates a reference to eachs comments post, this is then used to to save comments to iCloud
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    // local init()
    init(text: String, post: Post, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.post = post
        self.timestamp = timestamp
        self.recordID = recordID
    }

    
    // this builds a model object once returned from iCloud
convenience init?(ckRecord: CKRecord, post: Post){
    guard let text = ckRecord[CommentConstants.textKey] as? String,
        let timestamp = ckRecord[CommentConstants.timestampKey] as? Date else { return nil }
    self.init(text: text, post: post, timestamp: timestamp, recordID: ckRecord.recordID)
}
}

// turns model object into a ckRecord
extension CKRecord {
convenience init(comment: Comment) {
    self.init(recordType: CommentConstants.recordType, recordID: comment.recordID)
    self.setValue(comment.postReference, forKey: CommentConstants.postReferenceKey)
    self.setValue(comment.text, forKey: CommentConstants.textKey)
    self.setValue(comment.timestamp, forKey: CommentConstants.timestampKey)
}
}


extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
}

struct CommentConstants {
    static let recordType = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
}




