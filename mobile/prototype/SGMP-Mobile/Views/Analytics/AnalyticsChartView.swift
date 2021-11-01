//
//  AnalyticsChartView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/31/21.
//

import SwiftUI
import Toast
import SwiftUICharts

enum AnalyticsChartTimeMode : Hashable {
    case ten_min
    case one_hour
    case six_hour
    case custom
}

struct AnalyticsChartTimePair : Codable, Equatable {
    var from : Date
    var to : Date
}

struct AnalyticsChartView: View {
    
    @Namespace private var animation
    @State var analytics : DefinedAnalytics
    @State var houseId : UInt64
    @State var loading : Bool = false
    
    @State var timeMode : AnalyticsChartTimeMode = .ten_min
    @State var time : AnalyticsChartTimePair = .init(from: .now, to: .now.advanced(by: -60 * 10))
    
    @State var chartData : LineChartData = .init(dataSets: .init(dataPoints: []))
    
    func refresh (newTime : AnalyticsChartTimePair? = nil) {
        loading = true
        let from = newTime?.from ?? time.from
        let to = newTime?.to ?? time.to
        NetworkManager.shared.getAnalyticsTimeSeries(houseId: houseId, startDate: from, endDate: to, analyticsName: analytics.name, interval: to.timeIntervalSince(from) * 1000.0 / 200.0 ) { frames, err in
            if let err = err {
                print("\(err)")
                Toast.default(image: .init(systemName: "xmark")!, title: "\(err.localizedDescription)").show(haptic: .error)
            } else if let frames = frames {
                Toast.default(image: .init(systemName: "checkmark")!, title: "Showing data frames (\(frames.count))", subtitle: "From \(from.formatted()) to \(to.formatted())").show(haptic: .success)
                let metadata = ChartMetadata(title: "\(analytics.description)", subtitle: "From \(from.formatted()) to \(to.formatted())")
                
                let gridStyle  = GridStyle(numberOfLines: 10,
                                                   lineColour   : Color(.lightGray).opacity(0.5),
                                                   lineWidth    : 1,
                                                   dash         : [8],
                                                   dashPhase    : 0)
                
                let chartStyle = LineChartStyle(infoBoxPlacement    : .floating,
                                                        infoBoxBorderColour : Color.primary,
                                                        infoBoxBorderStyle  : StrokeStyle(lineWidth: 1),
                                                        
                                                        markerType          : .vertical(attachment: .line(dot: .style(DotStyle()))),
                                                        
                                                        xAxisGridStyle      : gridStyle,
                                                        xAxisLabelPosition  : .bottom,
                                                        xAxisLabelColour    : Color.primary,
                                                        
                                                        yAxisGridStyle      : gridStyle,
                                                        yAxisLabelPosition  : .leading,
                                                        yAxisLabelColour    : Color.primary,
                                                        yAxisNumberOfLabels : 10,
                                                        yAxisLabelType: .numeric,
                                                        
                                                        globalAnimation     : .easeInOut)
                
                let dataPoints : [LineChartDataPoint] = frames.compactMap { frame in
                    let date = Date.init(timeIntervalSince1970: Double(frame.timestamp)/1000.0)
                    return LineChartDataPoint(value: frame.value, xAxisLabel: "\(frame.value.formatted(.number))", description: "\(date.formatted())", date: date)
                }
                let dataSets = LineDataSet.init(dataPoints: dataPoints,
                                                legendTitle: "\(analytics.description)",
                                                pointStyle: PointStyle(),
                                                style: LineStyle(lineColour: ColourStyle(colour: .init(uiColor: UIColor.label)), lineType: .curvedLine))
                let newChartData = LineChartData.init(dataSets: dataSets, metadata: metadata, chartStyle: chartStyle)
                DispatchQueue.main.async {
                    self.chartData = newChartData
                }
            }
            loading = false
        }
    }
    
    var body: some View {
        Group {
            Picker("Time Duration", selection: $timeMode) {
                Text("10 min").tag(AnalyticsChartTimeMode.ten_min)
                Text("1 hr").tag(AnalyticsChartTimeMode.one_hour)
                Text("6 hr").tag(AnalyticsChartTimeMode.six_hour)
                Text("more").tag(AnalyticsChartTimeMode.custom)
            }
            .onChange(of: timeMode, perform: { newTimeMode in
                switch newTimeMode {
                case .ten_min:
                    time.to = .now
                    time.from = .now.advanced(by: -60 * 10)
                    break
                case .one_hour:
                    time.to = .now
                    time.from = .now.advanced(by: -60 * 60)
                    break
                case .six_hour:
                    time.to = .now
                    time.from = .now.advanced(by: -60 * 360)
                    break
                case .custom:
                    break
                }
            })
            .onChange(of: time, perform: { newValue in
                refresh(newTime: newValue)
            })
            .pickerStyle(.segmented)
            
            if (timeMode == .custom) {
                DatePicker("From", selection: $time.from)
                DatePicker("To", selection: $time.to)
            }
            
            ZStack {
                LineChart(chartData: chartData)
                    .id(chartData.id)
                    .floatingInfoBox(chartData: chartData)
                    .touchOverlay(chartData: chartData, specifier: "%.0f")
                    .xAxisGrid(chartData: chartData)
                    .yAxisGrid(chartData: chartData)
                    .yAxisLabels(chartData: chartData)
                    .legends(chartData: chartData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                    .frame(maxWidth: .infinity, minHeight: 400, maxHeight: 400, alignment: .center)
                    .contextMenu {
                        Button {
                            
                        } label: {
                            Label {
                                Text("Share chart")
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                if loading {
                    Color.init(UIColor.secondaryLabel).opacity(0.5)
                        .overlay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                }
            }
        }
        .onAppear(perform: {
            if !loading {
                refresh(newTime: self.time)
            }
        })
    }
}

//struct AnalyticsChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnalyticsChartView()
//    }
//}
