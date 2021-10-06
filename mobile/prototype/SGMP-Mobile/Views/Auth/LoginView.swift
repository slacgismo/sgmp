//
//  LoginView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/29/21.
//

import Amplify
import SwiftUI
import Defaults

struct LoginView: View {
    @EnvironmentObject var env : Env
    @State private var username = ""
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
                        TextField("Username", text: $username)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        SecureField("Password", text: $password)
                    }
                } header: {
                    Text("Credentials")
                } footer: {
                    HStack {
                        Link("Register", destination: URL(string: "https://www6.slac.stanford.edu/")!)
                        Text(" / ")
                        Button("Reset") {
                            env.authState = .resetPassword(nil)
                        }
                    }
                }

                Section {
                    Button {
                        networking = true
                        Amplify.Auth.signIn(username: username, password: password) { result in
                            do {
                                // refer to https://docs.amplify.aws/lib/auth/signin_next_steps/q/platform/ios/
                                let signinResult = try result.get()
                                DispatchQueue.main.async {
                                    env.authState = .init(from: signinResult.nextStep)
                                }
                            } catch {
                                print ("Sign in failed \(error)")
                                errorMsg = "\(error)"
                            }
                            networking = false
                        }
                        password = ""
                    } label: {
                        Text(networking ? "Please wait ..." : "Login")
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                } footer: {
                    Text(errorMsg)
                        .foregroundColor(.red)
                }
            }.navigationTitle("Login")
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            username = ""
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
