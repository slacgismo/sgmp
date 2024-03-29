//
//  DeviceFormulaAnalyticsView.swift
//  SGMP-Mobile
//
//  Created by fincher on 11/8/21.
//

import SwiftUICharts
import SwiftUI
import Toast

struct DeviceFormulaAnalyticsView: View {
    
    @State var device : DeviceDetail
    @State var formula : String
    @State var loading : Bool = false

    @State var timeMode : AnalyticsChartTimeMode = .ten_min
    @State var time : AnalyticsChartTimePair = .init(from: .now.advanced(by: -60 * 10), to: .now)
    
    @State var chartData : LineChartData = .init(dataSets: .init(dataPoints: []))
    
    func refresh (newTime : AnalyticsChartTimePair? = nil) {
        let from = newTime?.from ?? time.from
        let to = newTime?.to ?? time.to
        loading = true
        NetworkManager.shared.getAnalyticsTimeSeries(houseId: device.house_id, startDate: from, endDate: to, forumla: formula, interval: to.timeIntervalSince(from) * 1000.0 / 200.0) { frames, err in
            if let err = err {
                print("\(err)")
//                Toast.default(image: .init(systemName: "xmark")!, title: "\(err.localizedDescription)").show(haptic: .error)
            } else if let frames = frames {
                Toast.default(image: .init(systemName: "checkmark")!, title: "Showing data frames (\(frames.count))", subtitle: "From \(from.formatted()) to \(to.formatted())").show(haptic: .success)
                let metadata = ChartMetadata(title: "\(formula)", subtitle: "From \(from.formatted()) to \(to.formatted())")
                
                let gridStyle  = GridStyle(numberOfLines: 10,
                                                   lineColour   : Color.init(uiColor: UIColor.tertiaryLabel).opacity(0.2),
                                                   lineWidth    : 1,
                                                   dash         : [8],
                                                   dashPhase    : 0)
                
                let chartStyle = LineChartStyle(infoBoxPlacement    : .floating,
                                                infoBoxValueFont: .body.monospaced(), infoBoxDescriptionFont: .caption.monospaced(), infoBoxBorderColour : Color.primary,
                                                infoBoxBorderStyle  : StrokeStyle(lineWidth: 1),
                                                
                                                markerType          : .vertical(attachment: .line(dot: .style(DotStyle()))),
                                                
                                                xAxisGridStyle      : gridStyle,
                                                xAxisLabelPosition  : .bottom,
                                                xAxisLabelFont: .footnote.monospaced(),
                                                xAxisLabelColour    : Color.primary,
                                                
                                                xAxisTitleFont: .callout.monospaced(),
                                                yAxisGridStyle      : gridStyle,
                                                yAxisLabelPosition  : .leading,
                                                yAxisLabelFont: .footnote.monospaced(),
                                                yAxisLabelColour    : Color.primary,
                                                yAxisNumberOfLabels : 10,
                                                yAxisLabelType: .numeric,
                                                yAxisTitleFont: .callout.monospaced(),
                                                
                                                globalAnimation     : .easeInOut)
                
                let dataPoints : [LineChartDataPoint] = frames.compactMap { frame in
                    let date = Date.init(timeIntervalSince1970: Double(frame.timestamp)/1000.0)
                    if let value = frame.value {
                        return LineChartDataPoint(value: value, xAxisLabel: "\(value.formatted(.number))", description: "\(date.formatted())", date: date)
                    } else {
                        return nil
                    }
                }
                let dataSets = LineDataSet.init(dataPoints: dataPoints,
                                                legendTitle: "\(formula)",
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
                DatePicker("From", selection: $time.from).font(.body.monospaced())
                DatePicker("To", selection: $time.to).font(.body.monospaced())
            }
            
            ZStack {
                LineChart(chartData: chartData)
                    .id(chartData.id)
                    .floatingInfoBox(chartData: chartData)
                    .touchOverlay(chartData: chartData, specifier: "%.3f")
                    .xAxisGrid(chartData: chartData)
                    .yAxisGrid(chartData: chartData)
                    .yAxisLabels(chartData: chartData, specifier: "%.2f", colourIndicator: .none)
                    .averageLine(chartData: chartData, markerName: "Average", labelPosition: .yAxis(specifier: "%.1f"), labelFont: .footnote.monospaced(), lineColour: .init(UIColor.secondaryLabel), strokeStyle: StrokeStyle(lineWidth: 2, dash: [8,10]), addToLegends: true)
                    .legends(chartData: chartData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                    .padding()
                    .font(.footnote.monospaced())
                    .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 250, alignment: .center)
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
            if !loading && self.chartData.dataSets.dataPoints.isEmpty {
                refresh(newTime: self.time)
            }
        })
    }
}
