import SwiftUI
import SwiftData

// Enum MainScreen remains the same
enum MainScreen {
    case addBill
    case splitBill
    case splitDetail
}

// ViewModel remains the same


struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = HomeViewModel() // Use new name
    
    @Environment(\.modelContext) internal var modelContext
    @Query(sort: [SortDescriptor(\SDBillSplitRecord.splitSavedAt, order: .reverse)])
    internal var savedSplits: [SDBillSplitRecord]
    
    var body : some View {
        NavigationStack(path: $viewModel.path) {
            ZStack {
                // Background Image
                background
                mainContentView
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print(UIDevice.current.identifierForVendor?.uuidString ?? "Unknown")
                        // Action
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(viewModel.totalCredits)")
                                .fontWeight(.semibold)
                                .foregroundColor(.yellow)
                        }
                        .font(.subheadline)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.path.append(.addBill)
                    } label: {
                        Label("Add Bill", systemImage: "plus.circle.fill") // Enhanced button
                    }
                }
            }
            .navigationDestination(for: MainScreen.self, destination: navigationDestination)
            .navigationBarTitle("Split History") // More descriptive title
            .background(Color(.systemGroupedBackground).ignoresSafeArea()) // A subtle background for the whole view
        }
    }
}

// Preview
#Preview {
    HomeView()
}
