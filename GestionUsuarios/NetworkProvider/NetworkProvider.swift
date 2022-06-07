//
//  NetworkProvider.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 3/6/22.
//

import Foundation

class NetworkProvider {

    static let shared = NetworkProvider()
    private init() {}

    static let kBaseUrl = "https://61d1-62-83-237-119.eu.ngrok.io/api/"
    let statusOk = 200...499

    static func createRequest(endpoint: String, method: String) -> URLRequest {
        
        let url = kBaseUrl + endpoint
        
        var request : URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    public static func createUser(name: String, email: String, password: String){
        var request : URLRequest = createRequest(endpoint: "createUser", method: "POST")
        
        let body : [String: AnyHashable] = [
            "nombre" : name,
            "email" : email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, _, error in
            guard let data = data, error == nil else{
                print("Error en la llamada")
                return
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("SUCCESS:\n\(response)")
                UserDefaults.standard.set(true, forKey: "userCreated")
                
            }catch{
                print(error)
            }
        }
        
        task.resume()
    }
    
    
    
    
    
    public static func deleteUser(){
        var request : URLRequest = createRequest(endpoint: "deleteUser", method: "PUT")
                
        let apiKey = UserDefaults.standard.value(forKey: "apiKey") as! String
        request.addValue(apiKey, forHTTPHeaderField: "api_token")
        
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
                
            }catch{
                print(error)
            }
        }
        
        task.resume()
    }
}
