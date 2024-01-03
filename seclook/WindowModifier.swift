//
//  WindowModifier.swift
//  seclook
//
//  Created by Andrew Katz on 11/16/23.
//

import SwiftUI
import AppKit

struct WindowModifier: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            window.styleMask.remove(.resizable)
            window.styleMask.remove(.fullScreen)
        }
    }
}
