//
//  LoginView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/29/21.
//

import SwiftUI
import Defaults


/**
 The view for login
 */
struct LoginView: View {
    
    /**
        Field types for the `LoginView`
     */
    enum LoginField: Hashable {
        case email
        case password
    }
    
    @EnvironmentObject var env : Env
    
    /// Current input email
    @State private var email = ""
    
    /// Current input password
    @State private var password = ""
    
    /// Error message for login failure
    @State private var errorMsg : String = ""
    
    /// True if in network calls, used to show loading indicator
    @State private var networking : Bool = false
    @FocusState private var focusedField: LoginField?
    
    
    /// Log in with `email` and `password`, return if either of them is empy
    /// - Note: `password` is always set to empty after this call
    func login() {
        if email.isEmpty || password.isEmpty {
            return
        }
        networking = true
        NetworkManager.shared.login(email: email, password: password) { response, err in
            if let err = err {
                errorMsg = "\(err)"
            } else if let response = response {
                if let message = response.message, response.status != "ok" {
                    errorMsg = "\(message)"
                }
                else if let profile = response.profile,
                        let refreshToken = response.refresh_token,
                        let accessToken = response.accesstoken {
                    Defaults[.userProfile] = .init(profileResponse: profile, accessToken: accessToken, refreshToken: refreshToken)
                }
            }
            networking = false
        }
        password = ""
    }
    
    
    /// The view
    var body: some View {
        NavigationView {
            List {
                Section {
                    if networking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.body.monospaced())
                            .focused($focusedField, equals: .email)
                            .submitLabel(SubmitLabel.next)
                            .onSubmit {
                                focusedField = .password
                            }
                        SecureField("Password", text: $password)
                            .font(.body.monospaced())
                            .focused($focusedField, equals: .password)
                            .submitLabel(SubmitLabel.go)
                            .onSubmit {
                                login()
                            }
                    }
                } header: {
                    Text("Credentials")
                } footer: {
                    HStack {
                        Link("Register", destination: URL(string: "https://www6.slac.stanford.edu/")!)
//                        Text(" / ")
//                        Button("Reset") {
//                            env.authState = .resetPassword(nil)
//                        }
                    }
                }

                Section {
                    Button {
                        login()
                    } label: {
                        Text(networking ? "Please wait ..." : "Login")
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                } footer: {
                    Text(errorMsg)
                        .foregroundColor(.red)
                }
            }.navigationTitle("Login")
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            email = ""
            password = ""
            errorMsg = ""
            networking = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
