//
//  QRCode.swift
//  MatrixBarcodeApp
//
//  Created by Romero Peces Barba, Kevin on 24/10/22.
//

import UIKit

import QRCode

extension QRCode {
    static func defaultImage(string: String) -> UIImage? {
        try? QRCode(
            string: string,
            color: .accentColor,
            backgroundColor: .clear,
            scale: 10.0,
            inputCorrection: .high
        )?.image()
    }
}
