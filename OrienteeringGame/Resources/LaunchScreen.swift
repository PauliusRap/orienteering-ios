import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "compass.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color(hex: "0A0A0F"))
                }
                
                Text("Orienteering")
                    .font(.custom("Avenir-Black", size: 32))
                    .foregroundColor(.white)
                
                Text("Find Your Adventure")
                    .font(.custom("Avenir-Book", size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
