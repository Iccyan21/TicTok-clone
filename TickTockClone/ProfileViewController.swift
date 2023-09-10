//
//  ProfileViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/25.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        Api.User.logOut()
    }
    
}
