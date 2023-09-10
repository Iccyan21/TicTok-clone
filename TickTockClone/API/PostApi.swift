//
//  PostApi.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/09/03.
//

import Foundation
import ProgressHUD
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class PostApi {
    func sharePost(encodedVideoURL: URL?, selectedPhoto: UIImage?, textView: UITextView,onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        let creadationDate = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else {return}
        if let encodedVideoURLUnwrapped = encodedVideoURL {
                let videoIdString = "\(NSUUID().uuidString).mp4"
                let storageRef = Ref().storageRoot.child("posts").child(videoIdString)
                let metdata = StorageMetadata()
                storageRef.putFile(from: encodedVideoURLUnwrapped, metadata: metdata){ metdata, error in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    storageRef.downloadURL(completion: {[self] videoUrl, error in
                        if error != nil {
                            ProgressHUD.showError(error!.localizedDescription)
                            return
                        }
                        guard let videoUrlString = videoUrl?.absoluteString else {return}
                        // Database処理
                        uploadThumbnailImageToStorage(selectedPhoto: selectedPhoto) { postImageUrl in
                            let values = ["creationDate": creadationDate,
                                          "imageUrl": postImageUrl,
                                          "videoUrl":videoUrlString,
                                          "description": textView.text!,
                                          "likes": 0,
                                          "views": 0,
                                          "commentCount": 0,
                                          "uid": uid] as [String: Any]
                            let postId = Ref().databaseRoot.child("Posts").childByAutoId()
                            postId.updateChildValues(values,withCompletionBlock: { err, ref in
                                if error != nil {
                                    onError(error!.localizedDescription)
                                    return
                                }
                                guard let postKey = postId.key else {return}
                                Ref().databaseRoot.child("User-Posts").child(uid).updateChildValues([postKey: 1])
                                onSuccess()
                            })
                        }
                    })
                }
            }
    }
    func uploadThumbnailImageToStorage(selectedPhoto: UIImage?, completion: @escaping (String) -> ()){
        if let thumbnailImage = selectedPhoto, let imageData = thumbnailImage.jpegData(compressionQuality: 0.3) {
            let photoIdString = NSUUID().uuidString
            let storageRef = Ref().storageRoot.child("post_images").child(photoIdString)
            storageRef.putData(imageData, completion: { metdata, error in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: { imageUrl, error in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    guard let postImageUrl = imageUrl?.absoluteString else {return}
                    completion(postImageUrl)
                })
                
            })
        }
    }
    func observePost(completion: @escaping (Post) -> Void){
        Ref().databaseRoot.child("Posts").observe(.childAdded) { snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let newPost = Post.tramsformPostVideo(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    func observeFeedPosts(completion: @escaping (Post) -> Void){
        Ref().databaseRoot.child("Posts").observeSingleEvent(of: .value){ snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach{ child in
                if let dict = child.value as? [String: Any] {
                    let post = Post.tramsformPostVideo(dict: dict, key: child.key)
                    completion(post)
                }
            }
        }
    }
}

extension UIImageView {
    func loadImage(_ urlString: String?,onSuccess: ((UIImage) -> Void)? = nil){
        self.image = UIImage()
        guard let string = urlString else {return}
        guard let url = URL(string: string) else {return}
        
        self.sd_setImage(with: url) { image, error, type, url in
            if onSuccess != nil, error == nil {
                onSuccess!(image!)
            }
        }
    }
}
