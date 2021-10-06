//
//  DashboardGlanceCellView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/4/21.
//

import SwiftUI

struct DashboardGlanceCellView: View {
    
    @State var title : String = "Solar Power"
    @State var iconName : String = "sun.min"
    @State var iconColor : Color = Color.black
    @State var number : String = "128 KWH"
    
    var body: some View {
        GroupBox {
            HStack {
                ZStack {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(iconColor)
                }
                .frame(maxHeight: 48)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .padding(.leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.headline)
                    Text(number)
                        .font(.title).bold()
                }
                Spacer()
            }
        }
        .groupBoxStyle(ListCardGroupBoxStyle())
        .shadow(color: Color(uiColor: UIColor.secondaryLabel).opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct DashboardGlanceCellView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardGlanceCellView(title: "Test", number: "12km")
    }
}
