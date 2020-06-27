//
//  BrightnessControl.swift
//  Hyperion
//
//  Created by Hack, Thomas on 27.06.20.
//  Copyright © 2020 Hack, Thomas. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

extension HomeView {

    struct BrightnessControl: View {
        var store: Store<AppState, AppAction>

        var body: some View {
            WithViewStore(self.store) { viewStore in
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(text: "Brightness")
                    BrightnessSlider(percentage: viewStore.binding( get: { $0.brightness }, send: AppAction.updateBrightness))
                        .frame(height: 72)
                }
            }
        }
    }
}

struct BrightnessControl_Previews: PreviewProvider {
    static var previews: some View {
        HomeView.BrightnessControl(
            store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    apiClient: .live
                )
            )
        )
        .previewLayout(.fixed(width: 375, height: 120))
    }
}
