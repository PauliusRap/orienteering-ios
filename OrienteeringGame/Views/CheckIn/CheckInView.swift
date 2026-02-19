import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel: CheckInViewModel
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var activeHuntViewModel: ActiveHuntViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(clueId: String, huntId: String) {
        _viewModel = StateObject(wrappedValue: CheckInViewModel(clueId: clueId, huntId: huntId))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            if viewModel.isCheckInSuccessful {
                SuccessView(
                    points: viewModel.pointsEarned,
                    bonus: viewModel.bonusPoints
                ) {
                    activeHuntViewModel.completeCurrentClue()
                    dismiss()
                }
            } else {
                VStack(spacing: 0) {
                    headerSection
                    Spacer()
                    contentSection
                    Spacer()
                    actionSection
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let clue = activeHuntViewModel.currentClue {
                viewModel.setClue(clue)
                locationService.setTarget(latitude: clue.latitude, longitude: clue.longitude, checkInRadius: clue.radius)
            }
            locationService.startUpdatingLocation()
        }
        .onReceive(locationService.$currentLocation) { _ in
            viewModel.updateDistance(locationService: locationService)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "1F1F2E"))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Check In")
                .font(.custom("Avenir-Black", size: 22))
                .foregroundColor(.white)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private var contentSection: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: viewModel.isWithinRange ? [Color(hex: "10B981"), Color(hex: "059669")] : [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 8) {
                    Image(systemName: viewModel.isWithinRange ? "checkmark.circle.fill" : "location.fill")
                        .font(.system(size: 48))
                        .foregroundColor(viewModel.isWithinRange ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                    
                    Text(viewModel.formattedDistance)
                        .font(.custom("Avenir-Black", size: 36))
                        .foregroundColor(.white)
                    
                    Text("from target")
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
            }
            
            if let clue = viewModel.clue {
                VStack(spacing: 8) {
                    Text("Clue #\(clue.order)")
                        .font(.custom("Avenir-Heavy", size: 20))
                        .foregroundColor(.white)
                    
                    Text(clue.hint)
                        .font(.custom("Avenir-Book", size: 16))
                        .foregroundColor(Color(hex: "9CA3AF"))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
            }
            
            if viewModel.checkInFailed {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "EF4444"))
                    
                    Text(viewModel.errorMessage ?? "Get closer to check in!")
                        .font(.custom("Avenir-Medium", size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hex: "EF4444").opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Text(viewModel.isWithinRange ? "Ready to check in!" : "Move to the location")
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(viewModel.isWithinRange ? Color(hex: "10B981") : Color(hex: "6B7280"))
            
            Button {
                Task {
                    await viewModel.attemptCheckIn(locationService: locationService)
                }
            } label: {
                if viewModel.isVerifying {
                    ProgressView()
                        .tint(Color(hex: "0A0A0F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                } else {
                    Text("Verify Location")
                        .font(.custom("Avenir-Black", size: 18))
                        .foregroundColor(Color(hex: "0A0A0F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
            }
            .background(
                LinearGradient(
                    colors: viewModel.isWithinRange ? [Color(hex: "10B981"), Color(hex: "059669")] : [Color(hex: "4B5563"), Color(hex: "374151")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .disabled(!viewModel.isWithinRange || viewModel.isVerifying)
        }
        .padding(24)
    }
}

struct SuccessView: View {
    let points: Int
    let bonus: Int
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "10B981"), Color(hex: "059669")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: true)
            
            VStack(spacing: 8) {
                Text("Location Verified!")
                    .font(.custom("Avenir-Black", size: 28))
                    .foregroundColor(.white)
                
                Text("Excellent navigation skills!")
                    .font(.custom("Avenir-Book", size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("+\(points)")
                        .font(.custom("Avenir-Black", size: 32))
                        .foregroundColor(Color(hex: "EC4899"))
                    Text("Points")
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "151520"))
                .cornerRadius(16)
                
                VStack(spacing: 8) {
                    Text("+\(bonus)")
                        .font(.custom("Avenir-Black", size: 32))
                        .foregroundColor(Color(hex: "F59E0B"))
                    Text("Time Bonus")
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "151520"))
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: action) {
                Text("Continue")
                    .font(.custom("Avenir-Black", size: 18))
                    .foregroundColor(Color(hex: "0A0A0F"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
