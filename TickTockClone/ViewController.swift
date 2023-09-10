//
//  ViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookloginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googlesignUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        signUpButton.layer.cornerRadius = 18
        facebookloginButton.layer.cornerRadius = 18
        googlesignUpButton.layer.cornerRadius = 18
        loginButton.layer.cornerRadius = 18
 
    }
    
    @IBAction func SighUpDidTapped(_ sender: Any) {
        let storyborad = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyborad.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
       
    }
    
    @IBAction func signinDidTapped(_ sender: Any) {
        let storyborad = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyborad.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

