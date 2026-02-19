import SwiftUI

struct ActiveHuntView: View {
    @StateObject private var viewModel: ActiveHuntViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    
    init(huntId: String) {
        _viewModel = StateObject(wrappedValue: ActiveHuntViewModel(huntId: huntId))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(Color(hex: "F59E0B"))
            } else if viewModel.showingCompletion {
                CompletionView(
                    points: viewModel.progress?.earnedPoints ?? 0,
                    time: viewModel.formattedElapsedTime
                ) {
                    appState.endHunt()
                }
            } else {
                VStack(spacing: 0) {
                    headerSection
                    progressSection
                    clueSection
                    Spacer()
                    actionSection
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.load()
            locationService.startUpdatingLocation()
            if let location = viewModel.currentTargetLocation {
                locationService.setTarget(location: location)
            }
        }
        .onDisappear {
            locationService.clearTarget()
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "F59E0B"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "1F1F2E"))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(viewModel.hunt?.name ?? "Hunt")
                    .font(.custom("Avenir-Heavy", size: 16))
                    .foregroundColor(.white)
                
                Text(viewModel.formattedElapsedTime)
                    .font(.custom("Avenir-Black", size: 24))
                    .foregroundColor(Color(hex: "F59E0B"))
            }
            
            Spacer()
            
            Button {
                if let huntId = viewModel.hunt?.id {
                    appState.navigate(to: .mapView(huntId: huntId))
                }
            } label: {
                Image(systemName: "map")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "F59E0B"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "1F1F2E"))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.custom("Avenir-Book", size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                
                Spacer()
                
                Text("\(Int(viewModel.progressPercentage))%")
                    .font(.custom("Avenir-Heavy", size: 14))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "1F1F2E"))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (viewModel.progressPercentage / 100))
                }
            }
            .frame(height: 12)
            
            HStack(spacing: 8) {
                ForEach(Array(viewModel.clues.enumerated()), id: \.element.id) { index, clue in
                    Circle()
                        .fill(index < viewModel.currentClueIndex ? Color(hex: "10B981") :
                              index == viewModel.currentClueIndex ? Color(hex: "F59E0B") :
                              Color(hex: "2D2D3D"))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    private var clueSection: some View {
        VStack(spacing: 24) {
            if let clue = viewModel.currentClue {
                VStack(spacing: 16) {
                    Text("Clue #\(clue.order)")
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                        .tracking(2)
                    
                    Text(clue.title)
                        .font(.custom("Avenir-Black", size: 28))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "F59E0B").opacity(0.6))
                    
                    Text(clue.riddle)
                        .font(.custom("Avenir-Book", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "151520"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(hex: "2D2D3D"), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                HStack(spacing: 16) {
                    VStack {
                        Text("\(clue.points)")
                            .font(.custom("Avenir-Black", size: 28))
                            .foregroundColor(Color(hex: "EC4899"))
                        Text("Points")
                            .font(.custom("Avenir-Book", size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "151520"))
                    .cornerRadius(16)
                    
                    VStack {
                        Text("+\(clue.timeBonus)")
                            .font(.custom("Avenir-Black", size: 28))
                            .foregroundColor(Color(hex: "10B981"))
                        Text("Time Bonus")
                            .font(.custom("Avenir-Book", size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "151520"))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            if let distance = locationService.formattedDistance {
                HStack(spacing: 8) {
                    Circle()
                        .fill(locationService.isAtTarget ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                        .frame(width: 10, height: 10)
                    
                    Text(locationService.isAtTarget ? "You're at the location!" : "\(distance) away")
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundColor(locationService.isAtTarget ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                }
            }
            
            Button {
                if let clueId = viewModel.currentClue?.id {
                    appState.navigate(to: .checkIn(clueId: clueId))
                }
            } label: {
                Text("Check In")
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
        }
        .padding(24)
        .background(Color(hex: "0A0A0F"))
    }
}

struct CompletionView: View {
    let points: Int
    let time: String
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
            
            VStack(spacing: 8) {
                Text("Hunt Complete!")
                    .font(.custom("Avenir-Black", size: 32))
                    .foregroundColor(.white)
                
                Text("Great job, explorer!")
                    .font(.custom("Avenir-Book", size: 18))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("\(points)")
                        .font(.custom("Avenir-Black", size: 36))
                        .foregroundColor(Color(hex: "F59E0B"))
                    Text("Points Earned")
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(hex: "151520"))
                .cornerRadius(20)
                
                VStack(spacing: 8) {
                    Text(time)
                        .font(.custom("Avenir-Black", size: 36))
                        .foregroundColor(Color(hex: "EC4899"))
                    Text("Total Time")
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(hex: "151520"))
                .cornerRadius(20)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: action) {
                Text("Back to Home")
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
