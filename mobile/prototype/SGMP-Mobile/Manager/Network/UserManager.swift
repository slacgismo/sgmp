//
//  UserManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/26/21.
//

import Foundation

class UserManager : BaseManager {
    static let instance = UserManager()
    
    override class var shared : UserManager {
        return instance
    }
 
    func login(email: String, password: String, callback: @escaping ((UserLoginResponse?, Error?) -> Void)) -> Void {
        let requestData = UserLoginRequest(email: email, password: password)
        var request = URLRequest(url: SgmpHostUrl.appendingPathComponent("api/user/login"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        do {
            request.httpBody = try JSONEncoder().encode(requestData)
        } catch (let err) {
            callback(nil, err)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, err in
            if let err = err {
                callback(nil, err)
            } else if let data = data {
                do {
                    let userLoginResponse = try JSONDecoder().decode(UserLoginResponse.self, from: data)
                    callback(userLoginResponse , nil)
                } catch (let err) {
                    callback(nil, err)
                }
            }
        }.resume()
    }
}
