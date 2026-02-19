import SwiftUI

struct ProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                tabSection
                contentSection
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.load()
            }
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
            
            Text("Progress")
                .font(.custom("Avenir-Black", size: 22))
                .foregroundColor(.white)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
    
    private var tabSection: some View {
        HStack(spacing: 0) {
            ForEach(ProgressViewModel.ProgressTab.allCases, id: \.self) { tab in
                Button {
                    viewModel.selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.custom(viewModel.selectedTab == tab ? "Avenir-Heavy" : "Avenir-Book", size: 14))
                        .foregroundColor(viewModel.selectedTab == tab ? .white : Color(hex: "6B7280"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.selectedTab == tab ?
                            Color(hex: "F59E0B") :
                            Color.clear
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(4)
        .background(Color(hex: "1F1F2E"))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
                .tint(Color(hex: "F59E0B"))
            Spacer()
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else {
            switch viewModel.selectedTab {
            case .overview:
                overviewContent
            case .leaderboard:
                leaderboardContent
            case .history:
                historyContent
            }
        }
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "EF4444"))
            
            Text("Failed to load data")
                .font(.custom("Avenir-Heavy", size: 20))
                .foregroundColor(.white)
            
            Text(error)
                .font(.custom("Avenir-Book", size: 14))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await viewModel.load()
                }
            } label: {
                Text("Retry")
                    .font(.custom("Avenir-Black", size: 16))
                    .foregroundColor(Color(hex: "0A0A0F"))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(hex: "F59E0B"))
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var overviewContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "1F1F2E"), lineWidth: 12)
                            .frame(width: 160, height: 160)
                        
                        Circle()
                            .trim(from: 0, to: min(Double(viewModel.user?.completedHunts ?? 0) / 20.0, 1.0))
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 4) {
                            Text("#\(viewModel.playerRank)")
                                .font(.custom("Avenir-Black", size: 36))
                                .foregroundColor(.white)
                            Text("Global Rank")
                                .font(.custom("Avenir-Book", size: 12))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                    .padding(.top, 32)
                }
                
                HStack(spacing: 12) {
                    StatBox(
                        value: viewModel.user?.formattedPoints ?? "0",
                        label: "Total Points",
                        color: Color(hex: "EC4899")
                    )
                    
                    StatBox(
                        value: "\(viewModel.user?.completedHunts ?? 0)",
                        label: "Hunts Done",
                        color: Color(hex: "10B981")
                    )
                    
                    StatBox(
                        value: "\(viewModel.user?.currentStreak ?? 0)",
                        label: "Day Streak",
                        color: Color(hex: "EF4444")
                    )
                }
                
                if !viewModel.activeHunts.isEmpty {
                    VStack(spacing: 12) {
                        Text("Active Hunts")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(viewModel.activeHunts) { progress in
                            ActiveHuntCard(
                                progress: progress,
                                huntName: viewModel.getHuntName(for: progress.huntId)
                            )
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
    }
    
    private var leaderboardContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.leaderboard) { entry in
                    LeaderboardRow(
                        entry: entry,
                        isCurrentUser: entry.playerId == viewModel.user?.id
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
    }
    
    private var historyContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.completedHunts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "flag.slash")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "4B5563"))
                        
                        Text("No completed hunts yet")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundColor(Color(hex: "6B7280"))
                        
                        Text("Start exploring to build your history!")
                            .font(.custom("Avenir-Book", size: 14))
                            .foregroundColor(Color(hex: "4B5563"))
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(viewModel.completedHunts) { progress in
                        HistoryCard(
                            progress: progress,
                            huntName: viewModel.getHuntName(for: progress.huntId),
                            duration: viewModel.formatDuration(from: progress.startedAt, to: progress.completedAt)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.custom("Avenir-Black", size: 24))
                .foregroundColor(color)
            
            Text(label)
                .font(.custom("Avenir-Book", size: 12))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(hex: "151520"))
        .cornerRadius(16)
    }
}

struct ActiveHuntCard: View {
    let progress: PlayerProgress
    let huntName: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "flag.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "0A0A0F"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(huntName)
                    .font(.custom("Avenir-Heavy", size: 16))
                    .foregroundColor(.white)
                
                Text("\(Int(progress.progressPercentage))% complete")
                    .font(.custom("Avenir-Book", size: 13))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(progress.earnedPoints)")
                    .font(.custom("Avenir-Black", size: 18))
                    .foregroundColor(Color(hex: "EC4899"))
                
                Text("pts")
                    .font(.custom("Avenir-Book", size: 12))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
        .padding(16)
        .background(Color(hex: "151520"))
        .cornerRadius(16)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                if entry.rank <= 3 {
                    Circle()
                        .fill(rankGradient)
                        .frame(width: 44, height: 44)
                } else {
                    Circle()
                        .fill(Color(hex: "1F1F2E"))
                        .frame(width: 44, height: 44)
                }
                
                if entry.rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(entry.rank)")
                        .font(.custom("Avenir-Black", size: 16))
                        .foregroundColor(Color(hex: "6B7280"))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.playerName)
                    .font(.custom(isCurrentUser ? "Avenir-Heavy" : "Avenir-Medium", size: 16))
                    .foregroundColor(isCurrentUser ? Color(hex: "F59E0B") : .white)
                
                Text("\(entry.completedHunts) hunts completed")
                    .font(.custom("Avenir-Book", size: 12))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            
            Spacer()
            
            Text(entry.formattedPoints)
                .font(.custom("Avenir-Black", size: 18))
                .foregroundColor(Color(hex: "EC4899"))
        }
        .padding(16)
        .background(isCurrentUser ? Color(hex: "1F1F2E") : Color(hex: "151520"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrentUser ? Color(hex: "F59E0B") : Color.clear, lineWidth: 1)
        )
    }
    
    private var rankGradient: LinearGradient {
        switch entry.rank {
        case 1:
            return LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FFA500")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(colors: [Color(hex: "C0C0C0"), Color(hex: "808080")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3:
            return LinearGradient(colors: [Color(hex: "CD7F32"), Color(hex: "8B4513")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color(hex: "1F1F2E"), Color(hex: "1F1F2E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var rankIcon: String {
        switch entry.rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
}

struct HistoryCard: View {
    let progress: PlayerProgress
    let huntName: String
    let duration: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "10B981"), Color(hex: "059669")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(huntName)
                    .font(.custom("Avenir-Heavy", size: 16))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Label(duration, systemImage: "clock")
                    Label("\(progress.completedClueIds.count) clues", systemImage: "mappin")
                }
                .font(.custom("Avenir-Book", size: 12))
                .foregroundColor(Color(hex: "6B7280"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(progress.earnedPoints)")
                    .font(.custom("Avenir-Black", size: 18))
                    .foregroundColor(Color(hex: "10B981"))
                
                Text("pts")
                    .font(.custom("Avenir-Book", size: 12))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
        .padding(16)
        .background(Color(hex: "151520"))
        .cornerRadius(16)
    }
}
