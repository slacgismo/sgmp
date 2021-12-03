import SwiftUI
import Defaults
import ARKit
import Combine


/**
 A `ObservableObject` class that manages the tab bar selection, which provides a 'tab as button' implementation via `MainTabBarData.objectWillChange` property
 - SeeAlso: `MainTabView`
 */
final class MainTabBarData: ObservableObject {

    /// This is the index of the item that fires a custom action
    let customActiontemindex: Int
    let objectWillChange = PassthroughSubject<MainTabBarData, Never>()
    var previousItem: Int

    /// Computed property that checks if the current selection tab item is a custom action
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


/**
 Container view for the tab bar and all sub-pages when tab bar items were clicked
 */
struct MainTabView: View {
    
    /// A variable that syncs with `Defaults.Keys.debugMode`
    @Default(.debugMode) var debugMode
    
    /// Environment object inherited from `EnvironmentManager.env`
    @EnvironmentObject var env : Env
    
    /// The `MainTabBarData` to hold selected tab bar item
    @StateObject var tabData = MainTabBarData(initialIndex: 1, customItemIndex: 2)
    
    /// A variable that syncs with `Defaults.Keys.userProfile`
    @Default(.userProfile) var userProfile
    
    /// View
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
                
                if ARWorldTrackingConfiguration.isSupported || debugMode {
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
