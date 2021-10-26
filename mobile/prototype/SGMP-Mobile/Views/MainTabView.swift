import SwiftUI
import Defaults
import ARKit
import Combine

final class MainTabBarData: ObservableObject {

    /// This is the index of the item that fires a custom action
    let customActiontemindex: Int
    let objectWillChange = PassthroughSubject<MainTabBarData, Never>()
    var previousItem: Int
    var itemSelected: Int {
        didSet {
            if itemSelected == customActiontemindex {
                previousItem = oldValue
                itemSelected = oldValue
                isCustomItemSelected = true
            } else {
                isCustomItemSelected = false
            }
            objectWillChange.send(self)
        }
    }

    func reset() {
        itemSelected = previousItem
        objectWillChange.send(self)
    }

    /// This is true when the user has selected the Item with the custom action
    var isCustomItemSelected: Bool = false

    init(initialIndex: Int = 1, customItemIndex: Int) {
        self.customActiontemindex = customItemIndex
        self.itemSelected = initialIndex
        self.previousItem = initialIndex
    }
}

struct MainTabView: View {
    @EnvironmentObject var env : Env
    @StateObject var tabData = MainTabBarData(initialIndex: 1, customItemIndex: 2)
    @Default(.userProfile) var userProfile
    
    var body: some View {
        TabView(selection: $tabData.itemSelected) {
            if let userProfile = userProfile {
                NavigationView {
                    SummaryTabView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Summary", systemImage: "square.stack.3d.up")
                }
                .tag(1)
                
                if ARWorldTrackingConfiguration.isSupported {
                    NavigationView {
                        ZStack {}.navigationTitle("Camera")
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Label("Camera", systemImage: "arkit")
                    }
                    .tag(2)
                }
            }
            
            NavigationView {
                SettingsTabView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .sheet(isPresented: $tabData.isCustomItemSelected, onDismiss: {
            
        }, content: {
            ZStack(alignment: .topTrailing) {
                ARGridView()
                Button {
                    tabData.reset()
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
        })
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
