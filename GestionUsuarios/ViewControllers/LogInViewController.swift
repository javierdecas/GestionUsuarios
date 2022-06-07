//
//  LogInViewController.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 2/6/22.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var warnImage: UIImageView!
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Esconder teclado cuando no se use
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    

    @IBAction func logInProcess(_ sender: Any){
        errorLabel.text = ""
        if email.text?.isEmpty ?? true {
            errorLabel.text?.append(" - Introduzca un email.\n")
        }
        password.text?.isEmpty ?? true ? errorLabel.text?.append(" - Introduzca  una contraseña.\n") : errorLabel.text?.append("")
        Utilities.isEmailValid(email.text ?? "") ? errorLabel.text?.append("") : errorLabel.text?.append(" - Patrón de email incorrecto.\n")
        Utilities.isPasswordValid(password.text ?? "") ? errorLabel.text?.append("") : errorLabel.text?.append(" - Patrón de contraseña incorrecto\n")
        
        if errorLabel.text != "" {
            errorLabel.isHidden = false
            warnImage.isHidden = false
        }else{
            errorLabel.isHidden = true
            warnImage.isHidden = true
            logInUser(email: email.text!, password: password.text!)
        }
    }
    
    /**
     * Incluye código para esconder el teclado una vez se termina de escribir.
     */
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }


    private func goToMainScreen() {
        do {
            let logged = UserDefaults.standard.value(forKey: "loggedIn") as! Bool?
            
            if  logged != nil && logged == true{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "listaUsuarios", sender: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.errorLabel.text = "Fallo en la validación de Email/Contraseña, vuelva a intentarlo"
                    self.errorLabel.isHidden = false
                    self.warnImage.isHidden = false
                    
                }
                
            }
        }
        
    }
    
    /**
     * Función de LogIn
     * - parameter email email del empleado
     * - parameter password contraseña del empleado
     */
    func logInUser(email: String, password: String){
        var request : URLRequest = NetworkProvider.createRequest(endpoint: "login", method: "PUT")
        
        let body : [String: AnyHashable] = [
            "email" : email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else{
                print("Error en la llamada: " + (error?.localizedDescription ?? ""))
                return
            }
            
            do {
                let base64Encoded = data.base64EncodedString()
                let decodedData = Data(base64Encoded: base64Encoded)!
                let decodedString = String(data: decodedData, encoding: .utf8)!

                if(decodedString.starts(with: "{\"erro") == false){
                    let logInResponse : JsonStruct.LogInResponse = try JSONDecoder().decode(JsonStruct.LogInResponse.self, from: data)
                    UserDefaults.standard.set(logInResponse.token, forKey: "apiKey")
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                    UserDefaults.standard.set(email, forKey: "userEmail")
                }else{
                    UserDefaults.standard.set("", forKey: "apiKey")
                    UserDefaults.standard.set(false, forKey: "loggedIn")
                }
                self.goToMainScreen()
            }catch{
                UserDefaults.standard.set("", forKey: "apiKey")
                UserDefaults.standard.set(false, forKey: "loggedIn")
                print(error)
            }
        }
        
        task.resume()
    }
}
