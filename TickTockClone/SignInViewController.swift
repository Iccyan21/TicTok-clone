//
//  SignInViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/23.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var SignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupEmailTextfield()
        setupPasswordTextfield()
        setupView()
        
    }
    @IBAction func signInDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validateFields()
        self.signIn {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate){
                sd.configureIntialController()
            }
            
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
        
    }
}



extension SignInViewController {
    func signIn(onSuccess: @escaping() -> Void, onError:
                @escaping(_ errorMessage: String) -> Void){
        ProgressHUD.show("Loading....")
        Api.User.signIn(email: self.emailTextField.text!, password: self.passwordTextField.text!){
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMessage in
            onError(errorMessage)
        }
    }
    func validateFields () {
        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.showError("Please enter an email")
            return
        }
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            ProgressHUD.showError("Please enter an password")
            return
        }
    }
    
    func setupNavigationBar(){
        navigationItem.title = "Sign In"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
        func setupEmailTextfield(){
        emailContainer.layer.borderWidth = 1
        emailContainer.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        emailContainer.layer.cornerRadius = 20
        emailTextField.borderStyle = .none
    }
    func setupPasswordTextfield(){
        passwordContainer.layer.borderWidth = 1
        passwordContainer.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        passwordContainer.layer.cornerRadius = 20
        passwordTextField.borderStyle = .none
    }
    func setupView(){
        
        SignInButton.layer.cornerRadius = 18
    }
    
}
