import SwiftUI

struct PopupView: View {
    let contentType: String
    let onScan: () -> Void
    let onClose: () -> Void

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
            Text("Auto-closing in 10s...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 1.0)
        }
        .padding()
        .frame(width: 200, height: 150)
        .background(Color(red: 0.11764705882352941, green: 0.11764705882352941, blue: 0.11764705882352941))
        .cornerRadius(20)
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
