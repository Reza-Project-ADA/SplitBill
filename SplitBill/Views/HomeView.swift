//
//  HomeView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import SwiftUI
import SwiftData

enum MainScreen {
    case addBill
    case splitBill
    case splitDetail
}

struct HomeView: View {
    class ViewModel: ObservableObject {
        @Published var path: [MainScreen] = []
        @Published var receiptOutput: ReceiptOutput?
        @Published var selectedSplitSDRecord: SDBillSplitRecord?
    }
    @StateObject var viewModel: ViewModel = ViewModel()
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SDBillSplitRecord.splitSavedAt, order: .reverse)]) private var savedSplits: [SDBillSplitRecord]
    @State private var selectedSplit: SDBillSplitRecord? = nil
    
    var body : some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if savedSplits.isEmpty {
                    ContentUnavailableView(
                        "No Saved Splits",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Splits you save will appear here.")
                    )
                } else {
                    ForEach(savedSplits) { split in
                        Button {
                            viewModel.selectedSplitSDRecord = split
                            viewModel.path.append(.splitDetail)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(split.storeName)
                                    .font(.headline)
                                HStack {
                                    Text("Order: \(split.receiptOrderNumber)")
                                    Spacer()
                                    Text(split.receiptOriginalTotal, format: .currency(code: "IDR"))
                                }
                                .font(.subheadline)
                                Text("Saved: \(split.splitSavedAt)") // Relative time
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteSplits)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        viewModel.path.append(.addBill)
                    } label :{
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: MainScreen.self) { screen in
                switch screen {
                case .addBill:
                    AddBillView(receipt: $viewModel.receiptOutput)
                        .onDisappear {
                            if viewModel.receiptOutput != nil {
                                viewModel.path = [.splitBill]
                            }
                        }
                case .splitBill:
                    if let receipt = viewModel.receiptOutput {
                        SplitBillView(receipt: receipt)
                    } else {
                        EmptyView()
                    }
                case .splitDetail:
                    if let splitRecord = viewModel.selectedSplitSDRecord {
                        SavedSplitDetailView(splitRecord: splitRecord)
                            .onDisappear {
                                
                                viewModel.selectedSplitSDRecord = nil
                            }
                    } else {
                        EmptyView()
                    }
                    
                default:
                    EmptyView()
                }
            }
            .navigationBarTitle("Home")
        }
    }
    private func deleteSplits(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedSplits[$0] }.forEach(modelContext.delete)
            // SwiftData auto-saves changes in many contexts, or you can explicitly save:
            // try? modelContext.save()
        }
    }
}

#Preview {
    HomeView()
}
