//
//  UserProfileViewController.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 4/6/22.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var employeeMail: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var warnImage: UIImageView!
    
    @IBOutlet weak var changePassword: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let email = UserDefaults.standard.value(forKey: "userEmail") as! String?
        if  email != nil && email != "" {
            employeeMail.text = email
        }
        
        //Esconder teclado cuando no se use
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        view.addGestureRecognizer(tapGesture)

    }
    
    /**
     * Función que activa las validaciones y llama a cambiar contraseña
     * En caso de error activa el mensaje de error
     */
    @IBAction func changePasswordProcess(_ sender: Any){
        errorLabel.text = ""

        password.text?.isEmpty ?? true ? errorLabel.text?.append(" - Introduzca  una contraseña.\n") : errorLabel.text?.append("")
        Utilities.isPasswordValid(password.text ?? "") ? errorLabel.text?.append("") : errorLabel.text?.append(" - Patrón de contraseña incorrecto\n")
        
        if errorLabel.text != "" {
            errorLabel.isHidden = false
            warnImage.isHidden = false
        }else{
            errorLabel.isHidden = true
            warnImage.isHidden = true
            changePassword(password: password.text!)
        }
    }
    
    /**
     * Incluye código para esconder el teclado una vez se termina de escribir.
     */
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /**
     * Función para realizar el cambio de Contraseña
     * - parameter password nueva contraseña
     */
    func changePassword(password: String){
        var request : URLRequest = NetworkProvider.createRequest(endpoint: "changePass", method: "PUT")
        
        let body : [String: AnyHashable] = [
            "newPassword" : password
        ]
        let apiKey = UserDefaults.standard.value(forKey: "apiKey") as! String
        request.addValue(apiKey, forHTTPHeaderField: "api_token")
        
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
                print("SUCCESS:\n\(decodedString)")
                if(decodedString.starts(with: "{\"erro") == false){
                    DispatchQueue.main.async {
                        self.errorLabel.text = "La contraseña ha sido cambiada correctamente."
                    }
                }else{
                    DispatchQueue.main.async {
                        self.errorLabel.text = "La contraseña no ha sido cambiada. \nCompruebe su conexión con el servidor o inicie sesión de nuevo."
                        self.warnImage.isHidden = false
                    }
                }
                DispatchQueue.main.async {
                    self.errorLabel.isHidden = false
                }
                
            }catch{
                DispatchQueue.main.async {
                    self.errorLabel.text = "La contraseña no ha sido cambiada. \nCompruebe su conexión con el servidor o inicie sesión de nuevo."
                    self.warnImage.isHidden = false
                    
                }
                
            }
        }
        
        task.resume()
    }
    
    /**
     * Implementa la baja de un usuario en el sistema
     */
    @IBAction func deleteUser(_ sender: Any) {
        
        NetworkProvider.deleteUser()
        
        UserDefaults.standard.set("", forKey: "userEmail")
        UserDefaults.standard.set("", forKey: "apiKey")
        UserDefaults.standard.set(false, forKey: "loggedIn")
        UserDefaults.standard.set(false, forKey: "recoveredPass")
        UserDefaults.standard.set("", forKey: "apiRecoveredKey")
        
        performSegue(withIdentifier: "logOut", sender: nil)
    }
    
    /**
     * Implementa la función SignOut
     */
    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "userEmail")
        UserDefaults.standard.set("", forKey: "apiKey")
        UserDefaults.standard.set(false, forKey: "loggedIn")
        UserDefaults.standard.set(false, forKey: "recoveredPass")
        UserDefaults.standard.set("", forKey: "apiRecoveredKey")
        
        performSegue(withIdentifier: "logOut", sender: nil)
        
    }
}
