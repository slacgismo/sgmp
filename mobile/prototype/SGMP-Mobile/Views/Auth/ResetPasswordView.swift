//
//  ResetPasswordView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/5/21.
//

import SwiftUI

struct ResetPasswordView: View {
    var body: some View {
        NavigationView {
            List {
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
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
