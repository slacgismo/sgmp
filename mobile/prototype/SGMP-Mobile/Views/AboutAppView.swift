//
//  AboutAppView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/24/21.
//

import SwiftUI

struct AboutAppView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 0) {
                    Image("icon")
                        .resizable()
                        .frame(width: 128, height: 128, alignment: .center)
                        .mask(RoundedRectangle(cornerRadius: 24))
                        .padding()
                        .shadow(radius: 12)
                        .padding(.top, 32)
                    Text("SGMP Mobile")
                        .font(.title.bold().smallCaps())
                    Text("Ver \(Bundle.main.versionString ?? "-")")
                        .font(.footnote.bold().smallCaps())
                        .padding(.bottom, 32)
                        .foregroundColor(.init(UIColor.secondaryLabel))
                }.frame(maxWidth: .infinity)
                
                Link("Email", destination: URL(string: "mailto:gcezar@stanford.edu")!)
                Link("Slack", destination: URL(string: "https://practicum2021-team3.slack.com/archives/C02CT9C9BN2")!)
            }
            
        }
        .navigationTitle("About")
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
