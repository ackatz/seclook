import SwiftUI

struct PopupView: View {
    let contentType: String
    let onScan: () -> Void
    let onClose: () -> Void
    @State private var countdown = 10
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Text("seclook: Confirm Scan")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 1.0)
            Text("Do you want to scan the \(contentType) hash you copied?")
                .foregroundColor(.white)
            HStack {
                Button("Scan") {
                    onScan()
                    onClose()
                }
                .buttonStyle(ModernButtonStyle(backgroundColor: Color.blue))

                Button("Don't scan") {
                    onClose()
                }
                .buttonStyle(ModernButtonStyle(backgroundColor: Color.red))
                
            }
            // Countdown text
            if countdown > 0 {
                Text("Auto-closing in \(countdown)s")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 1.0)
            }
          
        }
        .padding()
        .frame(width: 200, height: 150)
        .background(Color(red: 0.11764705882352941, green: 0.11764705882352941, blue: 0.11764705882352941))
        .cornerRadius(20)
        .onAppear {
                    // Start the countdown when the view appears
                    startCountdown()
                }
                .onDisappear {
                    // Invalidate the timer when the view disappears
                    timer?.invalidate()
                }
    }
    
    private func startCountdown() {
           // Create and schedule a timer
           timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
               if countdown > 0 {
                   countdown -= 1
               } else {
                   timer?.invalidate() // Stop the timer
                   onClose() // Close the view
               }
           }
       }
}

// Preview Provider
struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(contentType: "SHA256", onScan: {}, onClose: {})
            .background(Color.black) 
            .previewLayout(.sizeThatFits)
    }
}
