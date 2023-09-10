//
//  Post.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/09/05.
//

import Foundation

class Post {
    var uid: String?
    var postId: String?
    var imageUrl: String?
    var videoUrl: String?
    var description: String?
    var creationDate: Date?
    var likes: Int?
    var views: Int?
    var commentCount: Int?
    
    static func tramsformPostVideo(dict: Dictionary<String, Any>, key: String) -> Post {
        let post = Post()
        post.postId = key
        post.uid = dict["uid"] as? String
        post.imageUrl = dict["imageUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.description = dict["description"] as? String
        post.likes = dict["likes"] as? Int
        post.views = dict["views"] as? Int
        post.commentCount = dict["commentCount"] as? Int
        let creationDouble = dict["creationDate"] as? Double ?? 0
        post.creationDate = Date(timeIntervalSince1970: creationDouble)
        return post
        
    }
}
