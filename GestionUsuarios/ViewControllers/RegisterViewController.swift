//
//  RegisterViewController.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 1/6/22.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordCheck: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var warnImage: UIImageView!
    @IBOutlet weak var registryButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Esconder teclado cuando no se use
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    /**
     * Validación del registro a mandar al servidor, donde comprobamos el Email, Nombre y Contraseña 
     */
    @IBAction func registryProcess(_ sender: Any) {
        errorLabel.text = ""
        name.text?.isEmpty ?? true ? errorLabel.text?.append(" - Introduzca un nombre.\n") : errorLabel.text?.append("")
        email.text?.isEmpty ?? true ? errorLabel.text?.append(" - Introduzca un email.\n") : errorLabel.text?.append("")
        password.text?.isEmpty ?? true ? errorLabel.text?.append(" - Introduzca una contraseña.\n") : errorLabel.text?.append("")
        passwordCheck.text != password.text ? errorLabel.text?.append(" - La contraseña debe coincidir en ambos campos.\n") : errorLabel.text?.append("")
        Utilities.isEmailValid(email.text ?? "") ? errorLabel.text?.append("") : errorLabel.text?.append(" - Patrón de email incorrecto.\n")
        Utilities.isPasswordValid(password.text ?? "") ? errorLabel.text?.append("") : errorLabel.text?.append(" - Patrón de contraseña incorrecto\n")
        
        if errorLabel.text != "" {
            errorLabel.isHidden = false
            warnImage.isHidden = false
        }else{
            errorLabel.isHidden = true
            warnImage.isHidden = true
            NetworkProvider.createUser(name: name.text!, email: email.text!, password: password.text!)
            goToLogIn()
        }
    }
    
    /**
     * Incluye código para esconder el teclado una vez se termina de escribir.
     */
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /**
     * Redirige a la página de LogIn si el registro fué OK
     */
    private func goToLogIn() {
        do {
            let created = UserDefaults.standard.value(forKey: "userCreated") as! Bool?
            if  created != nil && created == true{
                self.performSegue(withIdentifier: "logIn", sender: nil)
            }else{
                errorLabel.text = "Fallo en la validación de Email/Contraseña, vuelva a intentarlo"
                errorLabel.isHidden = false
                warnImage.isHidden = false
            }
        }
        
    }
}
