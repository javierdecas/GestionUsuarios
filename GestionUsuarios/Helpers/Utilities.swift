//
//  Utilities.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 1/6/22.
//

import Foundation
import UIKit

class Utilities {
    
    static func isEmailValid(_ email : String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[ñ^$@$#!%*?&=])[A-Za-z\\d^ñ$@$#!%*?&=]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    
    
}
