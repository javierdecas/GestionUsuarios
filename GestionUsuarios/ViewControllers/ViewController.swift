//
//  ViewController.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 29/5/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let logged = UserDefaults.standard.value(forKey: "loggedIn") as! Bool?
        
        if (logged != nil) && logged == true {
            performSegue(withIdentifier: "listUsers" , sender: nil)
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)
    }


}

