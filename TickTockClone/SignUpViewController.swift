//
//  SignUpViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import ProgressHUD


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passowrdTextField: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUsernameTextfield()
        setupEmailTextfield()
        setupPasswordTextfield()
        setupView()
    }
    
    func setupNavigationBar(){
        navigationItem.title = "Create new account"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupUsernameTextfield(){
        usernameContainerView.layer.borderWidth = 1
        usernameContainerView.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        usernameContainerView.layer.cornerRadius = 20
        usernameTextField.borderStyle = .none
    }
    func setupEmailTextfield(){
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        emailContainerView.layer.cornerRadius = 20
        emailTextField.borderStyle = .none
    }
    func setupPasswordTextfield(){
        passwordContainerView.layer.borderWidth = 1
        passwordContainerView.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        passwordContainerView.layer.cornerRadius = 20
        passowrdTextField.borderStyle = .none
    }
    
    func setupView(){
        avatar.layer.cornerRadius = 60
        SignUpButton.layer.cornerRadius = 18
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let tapGettrue = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGettrue)
    }
    
    func validateFields () {
        guard let username = self.usernameTextField.text, !username.isEmpty else {
            ProgressHUD.showError("Please enter an username")
            return
        }
        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.showError("Please enter an email")
            return
        }
        guard let password = self.passowrdTextField.text, !password.isEmpty else {
            ProgressHUD.showError("Please enter an password")
            return
        }
    }
    
    
    
    
    //サインイン処理
    @IBAction func signUpDidTapped(_ sender: Any) {
        self.validateFields()
        self.signUp {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
                sd.configureIntialController()
            }
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
        
    }
}
// 写真設定
extension SignUpViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self){ image, error in
                if let imageSelected = image as? UIImage{
                    DispatchQueue.main.async {
                        self.avatar.image = imageSelected
                        self.image = imageSelected
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    
    
    @objc func presentPicker() {
        var configuration: PHPickerConfiguration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 1
        
        let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
}

extension SignUpViewController{
    func signUp(onSuccess: @escaping() -> Void, onError:
                @escaping(_ errorMessage: String) -> Void){
        ProgressHUD.show("Lodding...")
        Api.User.signUp(withUsername: self.usernameTextField.text!, email: self.emailTextField.text!, password: self.passowrdTextField.text!, image: self.image){
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMessage in
            onError(errorMessage)
        }
    }
}
