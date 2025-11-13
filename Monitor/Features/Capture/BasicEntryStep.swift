import SwiftUI
import PhotosUI

struct BasicEntryStep: View {
    @Binding var foodAndDrink: String
    @Binding var mealType: MealType
    @Binding var timestamp: Date
    @Binding var location: String
    @Binding var photo: Data?
    let onContinue: () -> Void

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @FocusState private var isFoodFieldFocused: Bool
    @StateObject private var photoService = PhotoService()

    var isValid: Bool {
        foodAndDrink.trimmingCharacters(in: .whitespacesAndNewlines).count >= Config.minFoodDescriptionLength
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Progress indicator
            ProgressBar(currentStep: 1, totalSteps: 3)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Title
                    Text("What did you have?")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.Colors.text)

                    // Photo section
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Photo (optional)")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        if let image = selectedImage {
                            // Show captured image
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(Theme.CornerRadius.md)

                                Button(action: {
                                    selectedImage = nil
                                    photo = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .padding(Theme.Spacing.xs)
                            }
                        } else {
                            // Photo options
                            HStack(spacing: Theme.Spacing.sm) {
                                Button(action: { showCamera = true }) {
                                    Label("Camera", systemImage: "camera.fill")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Colors.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(Theme.Spacing.sm)
                                        .background(Theme.Colors.primary.opacity(0.1))
                                        .cornerRadius(Theme.CornerRadius.md)
                                }

                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Label("Library", systemImage: "photo")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Colors.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(Theme.Spacing.sm)
                                        .background(Theme.Colors.primary.opacity(0.1))
                                        .cornerRadius(Theme.CornerRadius.md)
                                }
                            }
                        }
                    }

                    // Food description
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("What did you eat or drink? *")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("e.g., Turkey sandwich, apple, and water", text: $foodAndDrink, axis: .vertical)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .lineLimit(3...6)
                            .focused($isFoodFieldFocused)

                        if !foodAndDrink.isEmpty && foodAndDrink.count < Config.minFoodDescriptionLength {
                            Text("Please describe what you had (minimum 3 characters)")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    // Meal type
                    MealTypePicker(selectedMealType: $mealType)

                    // Time
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("When?")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        DatePicker(
                            "",
                            selection: $timestamp,
                            in: ...Date(),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .tint(Theme.Colors.primary)
                    }

                    // Location
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Where? (optional)")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("e.g., Home, work, restaurant", text: $location)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.text)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                            .submitLabel(.done)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }

            // Continue button
            Button(action: onContinue) {
                HStack(spacing: 6) {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .font(Theme.Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .fill(isValid ? Theme.Colors.primary : Theme.Colors.textSecondary)
                )
            }
            .disabled(!isValid)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.sm)
        }
        .onAppear {
            // Auto-focus food field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFoodFieldFocused = true
            }
            // Auto-suggest time period based on timestamp
            mealType = MealType.suggestedType(for: timestamp)
        }
        .sheet(isPresented: $showCamera) {
            PhotoPicker(image: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let image = newValue {
                // Compress and save
                if let compressed = photoService.compressImage(image, maxSizeKB: Config.maxPhotoSizeKB) {
                    photo = compressed
                }
            }
        }
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Step \(currentStep) of \(totalSteps)")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.cardBackground)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.primary)
                        .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.sm)
    }
}