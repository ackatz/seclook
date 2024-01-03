//
//  WindowCustomizationView.swift
//  seclook
//
//  Created by Andrew Katz on 11/16/23.
//

import SwiftUI

struct WindowCustomizationView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            window.styleMask.remove(.resizable) // Make window non-resizable
            window.standardWindowButton(.zoomButton)?.isEnabled = false // Disable maximize button
        }
    }
}
