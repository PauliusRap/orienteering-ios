import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    statsSection
                    quickActionsSection
                    nearbyHuntsSection
                }
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.custom("Avenir-Book", size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
                
                Text(viewModel.player?.displayName ?? "Explorer")
                    .font(.custom("Avenir-Black", size: 28))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text(viewModel.player?.displayName.prefix(2).uppercased() ?? "EX")
                    .font(.custom("Avenir-Black", size: 18))
                    .foregroundColor(Color(hex: "0A0A0F"))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 32)
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Points",
                value: viewModel.player?.formattedPoints ?? "0",
                icon: "star.fill",
                color: Color(hex: "F59E0B")
            )
            
            StatCard(
                title: "Hunts",
                value: "\(viewModel.player?.completedHunts ?? 0)",
                icon: "flag.fill",
                color: Color(hex: "10B981")
            )
            
            StatCard(
                title: "Streak",
                value: "\(viewModel.player?.currentStreak ?? 0)",
                icon: "flame.fill",
                color: Color(hex: "EF4444")
            )
        }
        .padding(.horizontal, 24)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Start Adventure")
                .font(.custom("Avenir-Heavy", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 32)
            
            HStack(spacing: 16) {
                ActionCard(
                    title: "Find Hunt",
                    subtitle: "Explore nearby",
                    icon: "compass.fill",
                    gradient: [Color(hex: "8B5CF6"), Color(hex: "6D28D9")]
                ) {
                    appState.navigate(to: .huntSelection)
                }
                
                ActionCard(
                    title: "Progress",
                    subtitle: "View stats",
                    icon: "chart.bar.fill",
                    gradient: [Color(hex: "EC4899"), Color(hex: "BE185D")]
                ) {
                    appState.navigate(to: .progress)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var nearbyHuntsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Featured Hunts")
                    .font(.custom("Avenir-Heavy", size: 20))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    appState.navigate(to: .huntSelection)
                } label: {
                    Text("See All")
                        .font(.custom("Avenir-Medium", size: 14))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            ForEach(viewModel.nearbyHunts) { hunt in
                HuntCard(hunt: hunt) {
                    appState.startHunt(huntId: hunt.id)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.custom("Avenir-Black", size: 20))
                .foregroundColor(.white)
            
            Text(title)
                .font(.custom("Avenir-Book", size: 12))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "151520"))
        )
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.custom("Avenir-Heavy", size: 16))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.custom("Avenir-Book", size: 12))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "151520"))
            )
        }
    }
}

struct HuntCard: View {
    let hunt: Hunt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: difficultyGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    VStack(spacing: 2) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(hunt.totalClues)")
                            .font(.custom("Avenir-Black", size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(hunt.name)
                        .font(.custom("Avenir-Heavy", size: 18))
                        .foregroundColor(.white)
                    
                    Text(hunt.description)
                        .font(.custom("Avenir-Book", size: 13))
                        .foregroundColor(Color(hex: "6B7280"))
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(hunt.estimatedDuration) min", systemImage: "clock")
                        Label("\(hunt.totalPoints) pts", systemImage: "star.fill")
                    }
                    .font(.custom("Avenir-Medium", size: 12))
                    .foregroundColor(Color(hex: "9CA3AF"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "4B5563"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "151520"))
            )
        }
    }
    
    private var difficultyGradient: [Color] {
        switch hunt.difficulty {
        case .easy: return [Color(hex: "10B981"), Color(hex: "059669")]
        case .medium: return [Color(hex: "F59E0B"), Color(hex: "D97706")]
        case .hard: return [Color(hex: "EF4444"), Color(hex: "DC2626")]
        case .expert: return [Color(hex: "8B5CF6"), Color(hex: "7C3AED")]
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
