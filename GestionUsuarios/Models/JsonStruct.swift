//
//  JsonStruct.swift
//  GestionUsuarios
//
//  Created byJavier de castro on 4/6/22.
//

import Foundation

class JsonStruct {
    struct ListResponse : Codable { let response : [User] }
    struct User: Codable { let nombre: String }
    
    struct LogInResponse: Codable
    {
        let response : String
        let token : String
        
    }
}
