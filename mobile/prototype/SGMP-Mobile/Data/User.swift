//
//  UserModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/26/21.
//

import Foundation
import Defaults

// MARK: - User Model

/**
 User Profile data model that will be serialized into user defaults
 */
struct UserProfile : Codable, Defaults.Serializable {
    
    var email : String
    var name : String
    var roles : [String]
    
    /// Access token that will be used for network request
    var accessToken : String
    
    /// Last time access token refreshed
    var accessTokenUpdatedDate : Date
    
    /// The token used to refresh access token
    var refreshToken : String
    
    init(profileResponse: ProfileResponse, accessToken: String, refreshToken: String) {
        self.email = profileResponse.email
        self.name = profileResponse.name
        self.roles = profileResponse.roles
        self.accessToken = accessToken
        self.accessTokenUpdatedDate = .now
        self.refreshToken = refreshToken
    }
    
    init(user: UserProfile, newAccessToken: String) {
        self.email = user.email
        self.name = user.name
        self.roles = user.roles
        self.accessToken = newAccessToken
        self.refreshToken = user.refreshToken
        self.accessTokenUpdatedDate = .now
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

// MARK: - User Network

/// Response about the profile from the login and user/profile endpoint that will be embedded  in the `UserLoginResponse` model
struct ProfileResponse : Codable {
    var email : String
    var name : String
    var roles : [String]
    var house_id : UInt64
}


/// Request data model for the `//user/login` API
struct UserLoginRequest : Codable {
    var email : String
    var password : String
}


/// Login response to to `UserLoginRequest`
struct UserLoginResponse : Codable {
    var status : String
    var message : String?
    var accesstoken : String?
    var refresh_token : String?
    var profile : ProfileResponse?
    var houseId : UInt64?
    var houseDescription : String?
}


/// Request data model for refresh the access token. Need to supply a refresh token
struct RefreshTokenRequest :Codable {
    var refresh_token : String?
}


/// Response data model for the `RefreshTokenRequest` request
struct RefreshTokenResponse : Codable {
    var status : String
    var message : String?
    var accesstoken : String?
}
