import SwiftUI
import Defaults

struct MainTabView: View {
    @EnvironmentObject var env : Env
    
    @State private var emailAddress = ""
    @State private var password = ""
    @Default(.loginEmailAddress) var loginEmailAddress
    
    var body: some View {
        TabView {
            NavigationView {
                SummaryTabView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Summary", systemImage: "square.stack.3d.up")
            }
            
            NavigationView {
                CameraTabView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Camera", systemImage: "arkit")
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
            NavigationView {
                List {
                    Section {
                        TextField("Email", text: $emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        SecureField("Password", text: $password)
                    } header: {
                        Text("Credentials")
                    } footer: {
                        Link("Forgot login info?", destination: URL(string: "https://www6.slac.stanford.edu/")!)
                    }

                    Button {
                        loginEmailAddress = emailAddress
                        emailAddress = ""
                        password = ""
                    } label: {
                        Text("Login")
                    }
                    .disabled(emailAddress.isEmpty || password.isEmpty)
                }.navigationTitle("Login")
            }
            .interactiveDismissDisabled(true)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
