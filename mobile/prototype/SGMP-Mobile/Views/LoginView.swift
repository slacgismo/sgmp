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
    @State private var emailAddress = ""
    @State private var password = ""
    @Default(.loginEmailAddress) var loginEmailAddress
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Email", text: $emailAddress)
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
                    loginEmailAddress = emailAddress
                    emailAddress = ""
                    password = ""
//                    UserManager.shared.
                } label: {
                    Text("Login")
                }
                .disabled(emailAddress.isEmpty || password.isEmpty)
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
