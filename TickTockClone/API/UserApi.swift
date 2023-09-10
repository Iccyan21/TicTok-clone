//
//  UserApi.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/24.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD

class UserApi {
    func signIn(email:String,password: String,onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().signIn(withEmail: email, password: password){ authData, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            print(authData?.user.uid)
            onSuccess()
        }
        
    }
    
    func signUp(withUsername username: String, email: String,password: String,image: UIImage?,onSuccess: @escaping() -> Void, onError:
                @escaping(_ errorMessage: String) -> Void) {
        
            guard let imageSelected = image else {
                ProgressHUD.showError("Please enter an ProfileImage")
                return
            }
            guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else { return }
            
        Auth.auth().createUser(withEmail: email, password: password){
            authDataResult, error in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                print(authData.user.email)
                var dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL:authData.user.email,
                    USERNAME: username,
                    PROFILE_IMAGE_URL:"",
                    STATUS:""
                ]
                // Storage設定
               
                let storageProfileRef = Ref().storageSpesifcProfile(uid: authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfileRef, dict: dict){
                    onSuccess()
                } onError: { errorMessage in
                    onError(errorMessage)
                }
                
                
            }
        }
        
    }
    func observeUser(withId uid: String, complection: @escaping (User) -> Void){
        Ref().databaseRoot.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                complection(user)
            }
        })
    }
    
    
    
    func logOut(){
        do {
            try Auth.auth().signOut()
        } catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        let scene = UIApplication.shared.connectedScenes.first
        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
            sd.configureIntialController()
        }
    }
    
}
