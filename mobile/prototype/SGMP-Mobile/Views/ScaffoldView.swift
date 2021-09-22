//
//  ScaffoldView.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/21/21.
//

import SwiftUI

struct ScaffoldView: View {
    
    @EnvironmentObject var env : Env
    
    var body: some View {
        ZStack {
            MainTabView()
            
            env.decorationView
                .zIndex(9999)
                .opacity(env.showDecorationView ? 1 : 0)
                .offset(x: 0, y: env.showDecorationView ? 0 : -100)
                .allowsHitTesting(env.showDecorationView)
                .transition(.slide)
        }
    }
}

struct ScaffoldView_Previews: PreviewProvider {
    static var previews: some View {
        ScaffoldView()
    }
}
