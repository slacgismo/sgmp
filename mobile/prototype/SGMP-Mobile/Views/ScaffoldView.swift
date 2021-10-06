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
        MainTabView()
    }
}

struct ScaffoldView_Previews: PreviewProvider {
    static var previews: some View {
        ScaffoldView()
    }
}
