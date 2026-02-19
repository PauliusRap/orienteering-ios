import SwiftUI
import MapKit

struct HuntMapView: View {
    @StateObject private var viewModel: HuntMapViewModel
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    
    init(huntId: String) {
        _viewModel = StateObject(wrappedValue: HuntMapViewModel(huntId: huntId))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(Color(hex: "F59E0B"))
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                ZStack {
                    Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.annotations) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            MapPinView(order: viewModel.annotations.firstIndex(where: { $0.id == annotation.id }) ?? 0)
                        }
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        headerBar
                        Spacer()
                        locationList
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.load()
            }
            locationService.startUpdatingLocation()
        }
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "EF4444"))
            
            Text("Failed to load map")
                .font(.custom("Avenir-Heavy", size: 20))
                .foregroundColor(.white)
            
            Text(error)
                .font(.custom("Avenir-Book", size: 14))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Text("Go Back")
                        .font(.custom("Avenir-Black", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "1F1F2E"))
                        .cornerRadius(12)
                }
                
                Button {
                    Task {
                        await viewModel.load()
                    }
                } label: {
                    Text("Retry")
                        .font(.custom("Avenir-Black", size: 16))
                        .foregroundColor(Color(hex: "0A0A0F"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "F59E0B"))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "0A0A0F").opacity(0.8))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(viewModel.hunt?.name ?? "Map")
                .font(.custom("Avenir-Heavy", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hex: "0A0A0F").opacity(0.8))
                .cornerRadius(24)
            
            Spacer()
            
            Button {
                viewModel.centerOnUserLocation(locationService: locationService)
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "0A0A0F").opacity(0.8))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }
    
    private var locationList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.clues) { clue in
                    ClueCard(
                        clue: clue,
                        distance: locationService.distanceTo(latitude: clue.latitude, longitude: clue.longitude)
                    ) {
                        viewModel.centerOnClue(clue)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
}

struct MapPinView: View {
    let order: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .shadow(color: Color(hex: "F59E0B").opacity(0.4), radius: 8, x: 0, y: 4)
            
            Text("\(order + 1)")
                .font(.custom("Avenir-Black", size: 16))
                .foregroundColor(Color(hex: "0A0A0F"))
        }
    }
}

struct ClueCard: View {
    let clue: Clue
    let distance: Double?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F59E0B"))
                            .frame(width: 28, height: 28)
                        
                        Text("\(clue.order)")
                            .font(.custom("Avenir-Black", size: 14))
                            .foregroundColor(Color(hex: "0A0A0F"))
                    }
                    
                    Text("Clue #\(clue.order)")
                        .font(.custom("Avenir-Heavy", size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Text(clue.hint)
                    .font(.custom("Avenir-Book", size: 13))
                    .foregroundColor(Color(hex: "9CA3AF"))
                    .lineLimit(2)
                
                if let distance = distance {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(formatDistance(distance))
                    }
                    .font(.custom("Avenir-Medium", size: 12))
                    .foregroundColor(Color(hex: "10B981"))
                }
            }
            .padding(16)
            .frame(width: 180)
            .background(Color(hex: "0A0A0F").opacity(0.9))
            .cornerRadius(16)
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
