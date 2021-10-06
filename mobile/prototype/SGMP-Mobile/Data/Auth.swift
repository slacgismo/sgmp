//
//  Auth.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import Foundation
import Amplify

public enum AuthStates : Identifiable {
    public var id: Int {
        get {
            switch self {
            case .confirmSignInWithSMSMFACode(_, _):
                return 5
            case .confirmSignInWithCustomChallenge(_):
                return 4
            case .confirmSignInWithNewPassword(_):
                return 3
            case .resetPassword(_):
                return 2
            case .confirmSignUp(_):
                return 1
            case .login:
                return 0
            }
        }
    }
    
    /// Auth step is SMS multi factor authentication.
    ///
    /// Confirmation code for the MFA will be send to the provided SMS.
    case confirmSignInWithSMSMFACode(AuthCodeDeliveryDetails, AdditionalInfo?)

    /// Auth step is in a custom challenge depending on the plugin.
    ///
    case confirmSignInWithCustomChallenge(AdditionalInfo?)

    /// Auth step required the user to give a new password.
    ///
    case confirmSignInWithNewPassword(AdditionalInfo?)

    /// Auth step required the user to change their password.
    ///
    case resetPassword(AdditionalInfo?)

    /// Auth step that required the user to be confirmed
    ///
    case confirmSignUp(AdditionalInfo?)
    
    case login
    
    init?(from step : AuthSignInStep) {
        switch step {
        case .confirmSignInWithSMSMFACode(let authCodeDeliveryDetails, let optional):
            self = .confirmSignInWithSMSMFACode(authCodeDeliveryDetails, optional)
        case .confirmSignInWithCustomChallenge(let optional):
            self = .confirmSignInWithCustomChallenge(optional)
        case .confirmSignInWithNewPassword(let optional):
            self = .confirmSignInWithNewPassword(optional)
        case .resetPassword(let optional):
            self = .resetPassword(optional)
        case .confirmSignUp(let optional):
            self = .confirmSignUp(optional)
        case .done:
            return nil
        }
    }
}
