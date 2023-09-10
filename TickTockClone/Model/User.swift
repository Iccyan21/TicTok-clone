//
//  User.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/09/05.
//

import Foundation

class User {
    var uid: String?
    var profileImageUrl: String?
    var email: String?
    var username: String?
    var status: String?
    
    static func transformUser(dict: Dictionary<String, Any>, key: String) -> User {
        let user = User()
        user.uid = key
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.email = dict["email"] as? String
        user.username = dict["username"] as? String
        user.status = dict["status"] as? String
        return user
    }
}
