//
//  ResetPasswordView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import SwiftUI
import Amplify

struct ResetPasswordView: View {
    
    @EnvironmentObject var env : Env
    @State private var username = ""
    @State private var newPassword = ""
    @State private var verificationCode = ""
    @State private var noticeMsg : String = ""
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
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Button {
                            networking = true
                            Amplify.Auth.resetPassword(for: username, options: nil) { result in
                                do {
                                    let resetResult = try result.get()
                                    DispatchQueue.main.async {
                                        if case .done = resetResult.nextStep {
                                            UserManager.shared.refreshLoginState()
                                        } else if case .confirmResetPasswordWithCode(let deliveryDetails, let info)  = resetResult.nextStep {
                                            noticeMsg = "Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))"
                                        }
                                    }
                                } catch {
                                    print ("Request failed \(error)")
                                    errorMsg = "\(error)"
                                }
                                networking = false
                            }
                        } label: {
                            Text(networking ? "Please wait ..." : "Request Reset")
                        }
                        .disabled(username.isEmpty)
                    }
                } header: {
                    Text("Credentials")
                } footer: {
                    Text(noticeMsg)
                }
                
                if !username.isEmpty {
                    Section {
                        if networking {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            TextField("Verification Code", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                            SecureField("New Password", text: $newPassword)
                            
                            Button {
                                networking = true
                                Amplify.Auth.confirmResetPassword(for: username, with: newPassword, confirmationCode: verificationCode, options: nil) { result in
                                    do {
                                        let confirmNewPasswordResult = try result.get()
                                        DispatchQueue.main.async {
                                            env.authState = .login
                                        }
                                    } catch {
                                        print ("Confirm New Password failed \(error)")
                                        errorMsg = "\(error)"
                                    }
                                }
                                networking = false
                            } label: {
                                Text(networking ? "Please wait ..." : "Confirm New Password")
                            }.disabled(username.isEmpty || verificationCode.isEmpty || newPassword.isEmpty)
                        }
                    } footer: {
                        Text(errorMsg)
                            .foregroundColor(.red)
                    }
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
            .navigationTitle("Reset Password")
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            username = ""
            newPassword = ""
            verificationCode = ""
            errorMsg = ""
            noticeMsg = ""
            networking = false
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
