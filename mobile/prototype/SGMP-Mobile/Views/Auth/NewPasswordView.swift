//
//  NewPasswordView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import SwiftUI
import Amplify

struct NewPasswordView: View {
    @EnvironmentObject var env : Env
    @State private var newPassword = ""
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
                        SecureField("New Password", text: $newPassword)
                    }
                } header: {
                    Text("Credentials")
                } footer: {
                    Text("You need to set a new password in order to sign in")
                }

                Section {
                    Button {
                        networking = true
                        Amplify.Auth.confirmSignIn(challengeResponse: newPassword, options: nil) { result in
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
                        newPassword = ""
                    } label: {
                        Text(networking ? "Please wait ..." : "Set")
                    }
                    .disabled(newPassword.isEmpty)
                } footer: {
                    Text(errorMsg)
                        .foregroundColor(.red)
                }

            }
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button {
                        UserManager.shared.refreshLoginState()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            })
            .navigationTitle("Additional Steps")
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            newPassword = ""
            errorMsg = ""
            networking = false
        }
    }
}

struct NewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NewPasswordView()
    }
}
