//
//  Ref.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/24.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

let REF_USER = "users"
let STORAGE_PROFILE = "profile"
let URL_STORAAGE_ROOT = "gs://ticktok-clone-fd8b7.appspot.com"
let EMAIL = "email"
let UID = "uid"
let USERNAME = "username"
let PROFILE_IMAGE_URL = "profileImageUrl"
let STATUS = "status"

let IDENTIFIER_TABBAR = "TabbarVC"
let IDENTIFIER_MAIN = "MainVC"

class Ref {
    let databaseRoot = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
        
    func databaseSpesificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    // Storage Ref
    
    let storageRoot = Storage.storage().reference(forURL: URL_STORAAGE_ROOT)
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpesifcProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
}
