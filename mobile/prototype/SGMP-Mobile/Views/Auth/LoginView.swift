//
//  LoginView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/29/21.
//

import SwiftUI
import Defaults

struct LoginView: View {
    @EnvironmentObject var env : Env
    @State private var email = ""
    @State private var password = ""
    @State private var errorMsg : String = ""
    @State private var networking : Bool = false
    
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
                        SecureField("Password", text: $password)
                            .font(.body.monospaced())
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
                        networking = true
                        UserManager.shared.login(email: email, password: password) { response, err in
                            if let err = err {
                                errorMsg = "\(err)"
                            } else if let response = response {
                                if let message = response.message, response.status != "ok" {
                                    errorMsg = "\(message)"
                                }
                                else if let profile = response.profile, let token = response.accesstoken {
                                    Defaults[.userProfile] = .init(profileResponse: profile, token: token)
                                }
                            }
                            networking = false
                        }
                        password = ""
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
