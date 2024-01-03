//
//  FixedWindowSize.swift
//  seclook
//
//  Created by Andrew Katz on 11/16/23.
//

import AppKit

class FixedSizeWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        // Set the window style to non-resizable, closable, and miniaturizable
        window?.styleMask = [.titled, .closable, .miniaturizable]
        window?.isMovableByWindowBackground = true // Allow the window to be moved by dragging the background
    }
}
