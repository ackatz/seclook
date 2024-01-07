import SwiftUI
import AppKit

class PopupWindowController {
    private var popupWindow: NSWindow?
    private var closeTask: DispatchWorkItem?

    func showPopupWindow(contentType: String, onScan: @escaping () -> Void) {
        if popupWindow == nil {
            // Create the popup view with both onScan and onClose closures
            let popupContentView = PopupView(contentType: contentType, onScan: {
                onScan()
                self.hidePopupWindow()
            }, onClose: {
                self.hidePopupWindow()
            })

            let hostingController = NSHostingController(rootView: popupContentView)
            popupWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
                                   styleMask: [.borderless],
                                   backing: .buffered,
                                   defer: false)
            popupWindow?.contentViewController = hostingController
            positionWindow(popupWindow!)
        } else {
            // Update the content view for the existing window
            if let hostingController = popupWindow?.contentViewController as? NSHostingController<PopupView> {
                hostingController.rootView = PopupView(contentType: contentType, onScan: {
                    onScan()
                    self.hidePopupWindow()
                }, onClose: {
                    self.hidePopupWindow()
                })
            }
        }
        popupWindow?.makeKeyAndOrderFront(nil)
        
        // Schedule the window to close after 10 seconds
        let task = DispatchWorkItem { [weak self] in
            self?.hidePopupWindow()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
        closeTask = task
    }

    func hidePopupWindow() {
        popupWindow?.orderOut(nil)
        popupWindow = nil
        closeTask?.cancel()
    }

    private func positionWindow(_ window: NSWindow) {
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowRect = window.frame
            window.isOpaque = false
            window.backgroundColor = .clear
            let newOrigin = NSPoint(x: screenRect.maxX - windowRect.width - 20, y: screenRect.maxY - windowRect.height - 20)
            window.setFrameOrigin(newOrigin)
        }
    }

}
