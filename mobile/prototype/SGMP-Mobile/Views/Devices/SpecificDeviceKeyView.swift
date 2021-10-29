//
//  SpecificDeviceKeyView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI
import SwiftUICharts

struct SpecificDeviceKeyView: View {
    
    var key : String
    var deviceName : String
    @State private var timeDuration = -300
    @State private var date : (Date, Date) = (Date(timeIntervalSinceNow: -300), Date())
    @State var loadingChart : Bool = false
    @State var frames : [AnalyticsTimeSeriesFrame] = []
    
    func refresh(newDuration : Int) {
        loadingChart = true
        date = (Date(timeIntervalSinceNow: TimeInterval(newDuration)), Date())
        DataManager.shared.getAnalyticsTimeSeries(deviceName: deviceName, key: key, startDate: date.0, endDate: date.1) { frames, err in
            if let frames = frames {
                self.frames = frames
            } else if let err = err {
                print(err)
            }
            loadingChart = false
        }
    }
    
    var body: some View {
        VStack {
            Picker("Time Duration", selection: $timeDuration) {
                Text("5 min").tag(-300)
                Text("10 min").tag(-600)
                Text("30 min").tag(-1800)
                Text("1 hr").tag(-3600)
            }
            .onChange(of: timeDuration, perform: { newTimeDuration in
                refresh(newDuration: newTimeDuration)
            })
            .pickerStyle(.segmented)
            .padding()
            
            if loadingChart {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                LineChart()
                    .data(frames.map {frame in frame.value})
                    .chartStyle(ChartStyle(backgroundColor: .clear, foregroundColor: [ColorGradient(.init(uiColor: UIColor.label), .init(uiColor: UIColor.label))]))
                    .frame(height: 160)
                    .padding(.vertical)
                    .allowsHitTesting(false)
                
                List {
                    ForEach(frames.reversed()) { frame in
                        HStack {
                            Text("\(frame.value)")
                                .font(.body.monospaced())
                            Spacer()
                            Text("\(Date(timeIntervalSince1970: TimeInterval(Double(frame.timestamp) / 1000.0)), style: .relative) ago")
                                .font(.caption)
                                .foregroundColor(.init(uiColor: UIColor.secondaryLabel))
                        }
                    }
                }.listStyle(PlainListStyle())
            }
            
        }
        .onAppear(perform: {
            self.refresh(newDuration: timeDuration)
        })
        .navigationBarTitle(key)
    }
}

struct SpecificDeviceKeyView_Previews: PreviewProvider {
    static var previews: some View {
//        SpecificDeviceKeyView()
        ZStack {}
    }
}
