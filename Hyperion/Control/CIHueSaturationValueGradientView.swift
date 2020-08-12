//
//  CIHueSaturationValueGradientView.swift
//  Hyperion
//
//  Created by Hack, Thomas on 02.07.20.
//  Copyright © 2020 Hack, Thomas. All rights reserved.
//

import SwiftUI

struct CIHueSaturationValueGradientView: UIViewRepresentable {
    /// Radius to draw
    var radius: CGFloat

    /// The brightness/value of the wheel.
    @Binding var brightness: CGFloat

    /// Image view that will hold the rendered CIHueSaturationValueGradient.
    let imageView = UIImageView()

    func makeUIView(context: Context) -> UIImageView {
        /// Render CIHueSaturationValueGradient and set it to the ImageView that will be returned.
        imageView.image = renderFilter()
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        /// When the view updates eg. brightness changes, a new CIHueSaturationValueGradient will be generated.
        uiView.image = renderFilter()
    }

    /// Generate the CIHueSaturationValueGradient and output it as a UIImage.
    func renderFilter() -> UIImage {
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": CGColorSpaceCreateDeviceRGB(),
            "inputDither": 0,
            "inputRadius": radius * 0.4,
            "inputSoftness": 1,
            "inputValue": brightness
        ])!

        /// Output as UIImageView
        let image = UIImage(ciImage: filter.outputImage!)
        return image
    }
}

struct CIHueSaturationValueGradientView_Previews: PreviewProvider {
    static var previews: some View {
        CIHueSaturationValueGradientView(radius: 350, brightness: .constant(1))
            .previewLayout(.fixed(width: 350, height: 350))
    }
}