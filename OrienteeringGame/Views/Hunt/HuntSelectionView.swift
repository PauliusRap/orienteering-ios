import SwiftUI

struct HuntSelectionView: View {
    @StateObject private var viewModel = HuntSelectionViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(Color(hex: "F59E0B"))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredHunts) { hunt in
                                HuntSelectionCard(hunt: hunt) {
                                    appState.startHunt(huntId: hunt.id)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
        .onChange(of: viewModel.searchText) { _ in viewModel.applyFilters() }
        .onChange(of: viewModel.selectedDifficulty) { _ in viewModel.applyFilters() }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "6B7280"))
                        .frame(width: 40, height: 40)
                        .background(Color(hex: "1F1F2E"))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Choose Hunt")
                    .font(.custom("Avenir-Black", size: 22))
                    .foregroundColor(.white)
                
                Spacer()
                
                Circle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "6B7280"))
                
                TextField("Search hunts...", text: $viewModel.searchText)
                    .font(.custom("Avenir-Book", size: 16))
                    .foregroundColor(.white)
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                }
            }
            .padding(14)
            .background(Color(hex: "151520"))
            .cornerRadius(12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    DifficultyChip(
                        title: "All",
                        isSelected: viewModel.selectedDifficulty == nil
                    ) {
                        viewModel.selectedDifficulty = nil
                    }
                    
                    ForEach(HuntDifficulty.allCases, id: \.self) { difficulty in
                        DifficultyChip(
                            title: difficulty.rawValue,
                            isSelected: viewModel.selectedDifficulty == difficulty
                        ) {
                            viewModel.selectedDifficulty = difficulty
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}

struct HuntSelectionCard: View {
    let hunt: Hunt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(hunt.difficulty.rawValue.uppercased())
                                    .font(.custom("Avenir-Black", size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                    .tracking(2)
                            }
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(hunt.name)
                        .font(.custom("Avenir-Black", size: 22))
                        .foregroundColor(.white)
                    
                    Text(hunt.description)
                        .font(.custom("Avenir-Book", size: 14))
                        .foregroundColor(Color(hex: "9CA3AF"))
                        .lineLimit(2)
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "F59E0B"))
                            Text("\(hunt.estimatedDuration) min")
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "10B981"))
                            Text("\(hunt.totalClues) stops")
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "EC4899"))
                            Text("\(hunt.totalPoints) pts")
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                    }
                }
                .padding(20)
                .background(Color(hex: "151520"))
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var gradientColors: [Color] {
        switch hunt.difficulty {
        case .easy: return [Color(hex: "10B981"), Color(hex: "047857")]
        case .medium: return [Color(hex: "F59E0B"), Color(hex: "B45309")]
        case .hard: return [Color(hex: "EF4444"), Color(hex: "B91C1C")]
        case .expert: return [Color(hex: "8B5CF6"), Color(hex: "6D28D9")]
        }
    }
}

struct DifficultyChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Avenir-Medium", size: 14))
                .foregroundColor(isSelected ? .white : Color(hex: "9CA3AF"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "F59E0B") : Color(hex: "1F1F2E"))
                )
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
