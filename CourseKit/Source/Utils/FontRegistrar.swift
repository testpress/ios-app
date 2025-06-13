//
//  FontRegistrar.swift
//  ios-app
//
//  Created by Pruthivi Raj on 13/06/25.
//  Copyright © 2025 Testpress. All rights reserved.
//

import UIKit
import CoreText

public class FontRegistrar {
    @discardableResult
    public static func registerFont(
        withName fontName: String,
        fileExtension: String = "ttf",
        bundle: Bundle = Bundle.main
    ) -> Bool {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fileExtension) else {
            print("FontRegistrar: Font file \(fontName).\(fileExtension) not found in bundle.")
            return false
        }

        guard let dataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(dataProvider) else {
            print("FontRegistrar: Failed to create CGFont for \(fontName).")
            return false
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)

        if !success {
            if let error = error?.takeUnretainedValue() {
                print("FontRegistrar: Failed to register font: \(error.localizedDescription)")
            }
            return false
        }

        print("FontRegistrar: Registered font: \(font.fullName ?? fontName as CFString)")
        return true
    }

    public static func registerRubikFonts(bundle: Bundle = Bundle(for: FontRegistrar.self)) {
        _ = registerFont(withName: "Rubik-Regular", bundle: bundle)
        _ = registerFont(withName: "Rubik-Medium", bundle: bundle)
    }
}
