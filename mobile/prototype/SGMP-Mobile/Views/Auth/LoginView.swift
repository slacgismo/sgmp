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
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Username", text: $username)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                } header: {
                    Text("Credentials")
                } footer: {
                    Link("Forgot login info?", destination: URL(string: "https://www6.slac.stanford.edu/")!)
                }

                Button {
                    Amplify.Auth.signIn(username: username, password: password) {  result in
                        do {
                            // refer to https://docs.amplify.aws/lib/auth/signin_next_steps/q/platform/ios/
                            let signinResult = try result.get()
                            DispatchQueue.main.async {
                                env.authState = .init(from: signinResult.nextStep)
                            }
                        } catch {
                            print ("Sign in failed \(error)")
                        }
                    }
                    username = ""
                    password = ""
                } label: {
                    Text("Login")
                }
                .disabled(username.isEmpty || password.isEmpty)
            }.navigationTitle("Login")
        }
        .interactiveDismissDisabled(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
