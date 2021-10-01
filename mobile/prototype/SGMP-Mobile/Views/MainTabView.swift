import SwiftUI
import Defaults
import ARKit

struct MainTabView: View {
    @EnvironmentObject var env : Env
    
    var body: some View {
        TabView {
            NavigationView {
                SummaryTabView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Summary", systemImage: "square.stack.3d.up")
            }
            
            if ARWorldTrackingConfiguration.isSupported {
                NavigationView {
                    CameraTabView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Camera", systemImage: "arkit")
                }
            }
            
            NavigationView {
                SettingsTabView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .sheet(isPresented: $env.showLogin) {
            
        } content: {
            LoginView()
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
