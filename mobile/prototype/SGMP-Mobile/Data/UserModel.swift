//
//  UserModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/26/21.
//

import Foundation
import Defaults

struct UserProfile : Codable, Defaults.Serializable {
    
    var email : String
    var name : String
    var roles : [String]
    var accessToken : String
    
    init(profileResponse: ProfileResponse, token: String) {
        self.email = profileResponse.email
        self.name = profileResponse.name
        self.roles = profileResponse.roles
        self.accessToken = token
    }
}


enum UserException : Identifiable {
    public var id: Int {
        get {
            switch self {
            case .loggedOut:
                return 0
            }
        }
    }
    
    case loggedOut
}
