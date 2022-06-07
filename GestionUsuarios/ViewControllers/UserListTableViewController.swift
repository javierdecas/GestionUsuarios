//
//  UserListTableViewController.swift
//  GestionUsuarios
//
//  Created by Javier de Castro on 4/6/22.
//

import UIKit

class UserListTableViewController: UITableViewController {

    @IBOutlet weak var userTable: UITableView!
    
    var jsonObjectUsers : JsonStruct.ListResponse?
    var loading: Bool = true
    
    static let kBaseUrl = "https://61d1-62-83-237-119.eu.ngrok.io/api/"
    let statusOk = 200...499
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.titleView?.tintColor = UIColor.systemOrange
        listUsers()
        self.userTable.reloadData()
    }
    
    /**public func reloadTableAndIstertData(response: JsonStruct.ListResponse?){
        jsonObject = response
        userTable.reloadData()
        
    }*/
    
    public func listUsers(){
        var request : URLRequest = NetworkProvider.createRequest(endpoint: "list", method: "GET")
        let apiKey = UserDefaults.standard.value(forKey: "apiKey") as! String
        request.addValue(apiKey, forHTTPHeaderField: "api_token")
        var jsonObject : JsonStruct.ListResponse?
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else{
                print("Error en la llamada: " + (error?.localizedDescription ?? ""))
                return
            }
            
            do {
                print(data.base64EncodedString())
                jsonObject = try JSONDecoder().decode(JsonStruct.ListResponse.self, from: data)
                self.jsonObjectUsers = jsonObject
                print(self.jsonObjectUsers ?? "Error")
                self.loading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }catch{
                print(error)
                //fatalError("Error decoding data \(error)")
            }
        }
        
        task.resume()
    }
    
    //Populate Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonObjectUsers?.response.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = userTable.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as UITableViewCell

        if loading {
            cell.textLabel?.text = "Loading..."
        }else{
            cell.textLabel?.text = jsonObjectUsers?.response[indexPath.row].nombre
        }
        
        return cell
    }
}
