//
//  HomeView.swift
//  Hyperion
//
//  Created by Hack, Thomas on 26.06.20.
//  Copyright © 2020 Hack, Thomas. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    @Environment(\.scenePhase) private var scenePhase

    init(store: Store<Home.HomeFeatureState, Home.Action>) {
        self.store = store

        UINavigationBar.appearance().scrollEdgeAppearance = Appearance.transparentAppearance
        UINavigationBar.appearance().standardAppearance = Appearance.transparentAppearance
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    Color(.secondarySystemBackground)

                    if viewStore.connectivityState == .connected {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {

                                PriorityPreview(store: store)
                                
                                ConnectionHeader(store: store)

                                InstanceSelection(store: store)

                                BrightnessControl(store: store)

                                InstanceControl(store: store)

                                ComponentControl(store: store)

                                Spacer().frame(height: 48)
                            }
                            .padding()
                        }
                    }
                    else {
                        NotConnected(store: store)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .padding([.top], 10)
                .navigationBarTitle(Text("Hue Sync"), displayMode: .automatic)
                .navigationBarItems(
                    trailing:
                        HStack(spacing: 24) {
                            Button(action: {
                                viewStore.send(.powerButtonTapped)
                            }) {
                                Image(systemName: "power")
                                    .imageScale(.large)
                            }
                            .foregroundColor(viewStore.api.priorityShutdown || viewStore.connectivityState != .connected ? Color.red : Color(.label))

                            Button(action: {
                                viewStore.send(.connectButtonTapped)
                            }) {
                                Image(systemName: viewStore.connectivityState == .connected
                                        ? "bolt.fill"
                                        : viewStore.connectivityState == .disconnected
                                        ? "bolt.slash.fill"
                                        : "bolt")
                                    .imageScale(.large)
                            }
                            .foregroundColor(viewStore.connectivityState == .connected ? Color(.label) : Color.red)

                            Button(action: {
                                viewStore.send(.settingsButtonTapped)
                            }) {
                                Image(systemName: "gear")
                                    .imageScale(.large)
                            }
                            .foregroundColor(Color(.label))
                        }
                )
                .sheet(isPresented: viewStore.binding(
                        get: { $0.shared.showSettingsModal },
                        send: Home.Action.toggleSettingsModal)
                ) {
                    SettingsView(store: Main.store.settings)
                }
                .onAppear {
                    if viewStore.shared.host != nil && viewStore.connectivityState == .disconnected {
                        viewStore.send(.connectButtonTapped)
                    }
                }
                .onChange(of: scenePhase) { (newScenePhase) in
                    switch newScenePhase {
                    case .active:
                        print("scene is now active!")
                    case .inactive:
                        print("scene is now inactive!")
                    case .background:
                        print("scene is now in the background!")
                    @unknown default:
                        print("Apple must have added something new!")
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView(store: Main.previewStoreHome)
    }
}
