import SwiftUI
import Defaults
import ARKit

struct MainTabView: View {
    @EnvironmentObject var env : Env
    @Default(.userProfile) var userProfile
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var shouldPresentCameraView = false
    @State private var selectedItem = 1
    @State private var oldSelectedItem = 1
    
    var body: some View {
        TabView (selection: $selectedItem) {
            if let userProfile = userProfile {
                NavigationView {
                    SummaryTabView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Summary", systemImage: "square.stack.3d.up")
                }
                .onAppear { self.oldSelectedItem = self.selectedItem }
                
                if ARWorldTrackingConfiguration.isSupported {
                    NavigationView {
                        ZStack {}.navigationTitle("Camera")
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Label("Camera", systemImage: "arkit")
                    }
                    .onAppear {
                        self.shouldPresentCameraView.toggle()
                        self.selectedItem = self.oldSelectedItem
                    }
                    .sheet(isPresented: $shouldPresentCameraView) {
                        
                    } content: {
                        ZStack(alignment: .topTrailing) {
                            ARGridView()
                            Button {
                                shouldPresentCameraView = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.init(uiColor: UIColor.label))
                                    .padding()
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                        .interactiveDismissDisabled()
                    }

                }
            }
            
            NavigationView {
                SettingsTabView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .onAppear { self.oldSelectedItem = self.selectedItem }
        }
        .sheet(isPresented: $env.loginRequired, onDismiss: {
            
        }, content: {
            LoginView()
        })
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
