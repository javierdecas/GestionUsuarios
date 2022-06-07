//
//  RestorePasswordViewController.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 5/6/22.
//

import UIKit

class RestorePasswordViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var warnImage: UIImageView!
    @IBOutlet weak var restorePasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Esconder teclado cuando no se use
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    

    @IBAction func restorePasswordProcess(_ sender: Any){
        errorLabel.text = ""
        if email.text?.isEmpty ?? true {
            errorLabel.text?.append(" - Introduzca un email.\n")
        }
        Utilities.isEmailValid(email.text ?? "") ? errorLabel.text?.append("") : errorLabel.text?.append(" - Patrón de email incorrecto.\n")

        if errorLabel.text != "" {
            errorLabel.isHidden = false
            warnImage.isHidden = false
        }else{
            errorLabel.isHidden = true
            warnImage.isHidden = true
            restorePassword(email: email.text!)
            
        }
    }
    
    /**
     * Incluye código para esconder el teclado una vez se termina de escribir.
     */
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }


    private func checkIfWorked() {
        do {
            let logged = UserDefaults.standard.value(forKey: "recoveredPass") as! Bool?
            if  logged != nil && logged == true{
                DispatchQueue.main.async {
                    let newPass = UserDefaults.standard.value(forKey: "apiRecoveredKey") as! String
                    self.errorLabel.text = "Nueva Password: " + newPass
                    self.errorLabel.isHidden = false
                    
                }
            }
        }
        
    }
    
func restorePassword(email: String){
        var request : URLRequest = NetworkProvider.createRequest(endpoint: "recoverPass", method: "PUT")
                
        let body : [String: AnyHashable] = [
            "email" : email
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
                print("SUCCESS:\n\(decodedString)")
                if(decodedString.starts(with: "{\"erro") == false){
                    UserDefaults.standard.set(decodedString, forKey: "apiRecoveredKey")
                    UserDefaults.standard.set(true, forKey: "recoveredPass")
                }else{
                    UserDefaults.standard.set("", forKey: "apiRecoveredKey")
                    UserDefaults.standard.set(false, forKey: "recoveredPass")
                }
                self.checkIfWorked()
            }catch{
                UserDefaults.standard.set("", forKey: "apiRecoveredKey")
                UserDefaults.standard.set(false, forKey: "recoveredPass")
                print(error)
                self.checkIfWorked()
            }
        }
        
        task.resume()
    }

}
