// AddBillView.swift
import SwiftUI

struct AddBillView: View {
    @Environment(\.dismiss) var dismiss // For dismissing this view if needed later

    @StateObject var viewModel: AddBillViewModel = AddBillViewModel()
    // For showing alerts
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Binding var receipt: ReceiptOutput?

    var body: some View {
        VStack(spacing: 20) {
            Button {
                viewModel.showingActionSheet = true
            } label : {
                if let billImage = viewModel.billImage {
                    ZStack {
                        Image(uiImage: billImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 500)
                            .cornerRadius(10)
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .foregroundColor(.white)
                                .padding(5)
                            Text("Tap to replace")
                                .font(.caption)
                                .foregroundColor(.white)

                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(5)

                    }
                } else {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 400)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [5]))
                            )
                        Text("Select Bill Image")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                }
            }
            .buttonStyle(PlainButtonStyle())

            // TODO: Add other fields like amount, date, participants, etc.
            // For example:
            // TextField("Bill Amount", text: .constant(""))
            //     .textFieldStyle(RoundedBorderTextFieldStyle())

            Spacer()

            Button {
                // Clear previous errors before attempting
                viewModel.errorMessage = ""
                Task {
                    // The function now correctly awaits the full processing
                    let success = await viewModel.uploadImageAndProcess()
                    if success {
                        receipt = viewModel.receiptData!
                        // receiptData should be set by the viewModel if success is true
                        dismiss()
                    } else {
                        // Error message should be set in viewModel, optionally show an alert
                        if !viewModel.errorMessage.isEmpty {
                            alertMessage = viewModel.errorMessage
                            showAlert = true
                        }
                        print("Save Bill failed. Error: \(viewModel.errorMessage)")
                    }
                }
            } label: {
                if(viewModel.isLoading) {
                    Text("Loading...")
                } else {
                    Text("Scan Receipt")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(viewModel.billImage == nil || viewModel.isLoading ? Color.gray : Color.green) // Gray if no image or loading
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.billImage == nil || viewModel.isLoading) // Disable if no image or loading

        }
        .padding()
        .navigationTitle("New Bill")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Choose Image Source", isPresented: $viewModel.showingActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                viewModel.cameraButtonPressed()
            }
            Button("Photo Library") {
                viewModel.photoLibraryButtonPressed()
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: $viewModel.billImage, sourceType: viewModel.sourceType)
        }
        .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
    }
}

#Preview {
    NavigationView { // Wrap in NavigationView for previewing navigationBarTitle
        AddBillView(receipt: .constant(nil))
    }
}
