import SwiftUI
import UIKit
import Combine

struct CreateTideView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var locationService: LocationService
    
    // Form fields
    @State private var tideTitle: String = ""
    @State private var tideDescription: String = ""
    @State private var maxParticipants: String = "4"
    @State private var selectedCategory: TideCategory = .social
    @FocusState private var activeField: Field?
    
    // Animation state
    @State private var bubblePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = []
    @State private var animationCounter: Int = 0 // Simple counter for animation
    @State private var shouldAnimate: Bool = false
    
    // Keyboard state
    @State private var isKeyboardVisible: Bool = false
    
    // Validation state
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    // Soft gradient colors for the background
    let gradientColors = [
        Color(red: 0.20, green: 0.83, blue: 0.60), // Emerald-400 equivalent
        Color(red: 0.27, green: 0.87, blue: 0.67)  // Slightly lighter emerald
    ]
    
    enum Field: Hashable {
        case title, description, participants
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Static bubble overlay with controlled animations
                ZStack {
                    ForEach(0..<20, id: \.self) { i in
                        if i < bubblePositions.count {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: bubblePositions[i].size)
                                .position(x: bubblePositions[i].x, y: bubblePositions[i].y)
                                .animation(.easeInOut(duration: 0.7), value: animationCounter)
                        }
                    }
                }
                .onChange(of: shouldAnimate) { oldValue, newValue in
                    if newValue {
                        triggerBubbleAnimation()
                        // Auto-reset after animation is triggered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            shouldAnimate = false
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Title bar with back button and Done button when keyboard is visible
                    HStack {
                        Button {
                            animateBubbles()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding(.leading)
                        
                        Text("Create New Tide")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Done button that appears only when keyboard is visible
                        if isKeyboardVisible {
                            Button {
                                hideKeyboard()
                                animateBubbles()
                            } label: {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing)
                            .transition(.opacity)
                        } else {
                            // Empty view for spacing consistency
                            Color.clear
                                .frame(width: 44, height: 30)
                                .padding(.trailing)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    .animation(.easeInOut(duration: 0.2), value: isKeyboardVisible)
                    
                    // Form content
                    ScrollView {
                        VStack(spacing: 22) {
                            // Form card background
                            VStack(alignment: .leading, spacing: 18) {
                                // Title input
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Tide Title")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ZStack {
                                        TextField("", text: $tideTitle)
                                            .padding()
                                            .background(Color.black.opacity(0.2))
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                            .accentColor(.white)
                                            .focused($activeField, equals: .title)
                                            .onChange(of: activeField) { oldValue, newValue in
                                                // Update keyboard visibility state
                                                isKeyboardVisible = newValue != nil
                                            }
                                            .placeholder(when: tideTitle.isEmpty) {
                                                Text("Enter a title for your Tide")
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .padding(.leading, 16)
                                            }
                                        
                                        // Invisible button that covers the whole area
                                        Button(action: {
                                            activeField = .title
                                            animateBubbles()
                                        }) {
                                            Rectangle()
                                                .fill(Color.clear)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                // Description input
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Description")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ZStack(alignment: .topLeading) {
                                        if tideDescription.isEmpty {
                                            Text("Describe what your Tide is about")
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 16)
                                        }
                                        
                                        TextEditor(text: $tideDescription)
                                            .scrollContentBackground(.hidden)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 12)
                                            .frame(minHeight: 120)
                                            .background(Color.clear)
                                            .foregroundColor(.white)
                                            .accentColor(.white)
                                            .focused($activeField, equals: .description)
                                        
                                        // Invisible button covers the whole area
                                        Button(action: {
                                            activeField = .description
                                            animateBubbles()
                                        }) {
                                            Rectangle()
                                                .fill(Color.clear)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(10)
                                }
                                
                                // Max participants
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Maximum Participants")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ZStack {
                                        TextField("Enter maximum participants", text: $maxParticipants)
                                            .padding()
                                            .background(Color.black.opacity(0.2))
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                            .accentColor(.white)
                                            .keyboardType(.numberPad)
                                            .focused($activeField, equals: .participants)
                                            .onChange(of: maxParticipants) { _, newValue in
                                                // Allow only digits
                                                let filtered = newValue.filter { "0123456789".contains($0) }
                                                if filtered != newValue {
                                                    maxParticipants = filtered
                                                }
                                                
                                                // Enforce constraints on the value
                                                if let intValue = Int(filtered) {
                                                    if intValue < 2 {
                                                        // Don't update immediately to avoid UI confusion
                                                        // Just inform the user
                                                        if !filtered.isEmpty {
                                                            validationMessage = "Minimum number of participants must be 2"
                                                            showValidationAlert = true
                                                        }
                                                    } else if intValue > 10000 {
                                                        maxParticipants = "10000" // Cap at max value
                                                    }
                                                }
                                            }
                                        
                                        // Invisible button that covers the whole area
                                        Button(action: {
                                            activeField = .participants
                                            animateBubbles()
                                        }) {
                                            Rectangle()
                                                .fill(Color.clear)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Text("Minimum of 2, maximum of 10,000 participants allowed")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                // Category picker - Dropdown style with groups
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Category")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Menu {
                                        ForEach(TideCategory.categoriesByGroup().keys.sorted(), id: \.self) { group in
                                            if let categories = TideCategory.categoriesByGroup()[group] {
                                                Section(header: Text(group)) {
                                                    ForEach(categories, id: \.self) { category in
                                                        Button(action: {
                                                            selectedCategory = category
                                                            animateBubbles()
                                                        }) {
                                                            HStack {
                                                                Text(category.rawValue)
                                                                
                                                                if selectedCategory == category {
                                                                    Spacer()
                                                                    Image(systemName: "checkmark")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedCategory.rawValue)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.white.opacity(0.8))
                                                .font(.system(size: 14))
                                        }
                                        .padding()
                                        .background(Color.black.opacity(0.2))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            // Create button
                            Button {
                                animateBubbles()
                                validateAndCreateTide()
                            } label: {
                                ZStack {
                                    // Fancy gradient background
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.15, green: 0.45, blue: 0.40), // Deeper emerald
                                            Color(red: 0.10, green: 0.35, blue: 0.30)  // Dark emerald
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .cornerRadius(12)
                                    
                                    // Text with icon
                                    HStack {
                                        Image(systemName: "person.3.fill")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Create Tide")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 16) // Reduced vertical padding
                                }
                                .frame(maxWidth: .infinity)
                                .shadow(color: Color(red: 0.10, green: 0.30, blue: 0.25).opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping outside of text fields
                    hideKeyboard()
                }
            }
            .alert(validationMessage, isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                // Generate static bubble positions only once when view appears
                if bubblePositions.isEmpty {
                    generateBubblePositions(in: geometry)
                }
                
                // Trigger initial animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateBubbles()
                }
                
                // Setup notification for keyboard hiding
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    isKeyboardVisible = false
                }
            }
            .onDisappear {
                // Remove keyboard observers when view disappears
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIResponder.keyboardWillHideNotification,
                    object: nil
                )
            }
        }
    }
    
    // Helper function to hide keyboard
    private func hideKeyboard() {
        activeField = nil
        isKeyboardVisible = false
    }
    
    // Function to generate random bubble positions
    private func generateBubblePositions(in geometry: GeometryProxy) {
        bubblePositions = (0..<20).map { _ in 
            (
                x: CGFloat.random(in: 0...geometry.size.width),
                y: CGFloat.random(in: 0...geometry.size.height),
                size: CGFloat.random(in: 50...150)
            )
        }
    }
    
    // More reliable animation trigger function
    private func animateBubbles() {
        shouldAnimate = true
    }
    
    // Function to trigger bubble animation
    private func triggerBubbleAnimation() {
        // Slightly modify bubble positions to create movement
        for i in 0..<bubblePositions.count {
            // More significant random movement
            let xOffset = CGFloat.random(in: -60...60)
            let yOffset = CGFloat.random(in: -60...60)
            bubblePositions[i].x += xOffset
            bubblePositions[i].y += yOffset
        }
        
        // Increment counter to trigger animation
        animationCounter += 1
    }
    
    private func validateAndCreateTide() {
        // Basic validation
        if tideTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a title for your Tide"
            showValidationAlert = true
            return
        }
        
        if tideDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a description for your Tide"
            showValidationAlert = true
            return
        }
        
        // Validate participants
        guard let participantsCount = Int(maxParticipants) else {
            validationMessage = "Please enter a valid number for maximum participants"
            showValidationAlert = true
            return
        }
        
        if participantsCount < 2 {
            validationMessage = "Minimum number of participants must be 2"
            showValidationAlert = true
            return
        }
        
        if participantsCount > 10000 {
            validationMessage = "Maximum number of participants cannot exceed 10,000"
            showValidationAlert = true
            return
        }
        
        // Check if we have a valid bounding box from location service
        guard let boundingBox = locationService.boundingBox else {
            validationMessage = "Unable to determine your location. Please ensure location services are enabled."
            showValidationAlert = true
            return
        }
        
        // Check if we have valid user information
        guard let userId = userViewModel.user?.id,
              let username = userViewModel.user?.username,
              let adult = userViewModel.user?.adult else {
            validationMessage = "User information is missing. Please ensure you're logged in."
            showValidationAlert = true
            return
        }
        
        // Create the tide using the SingleTideViewModel
        Task {
            // Default adult content to false for now
            
            let creationStatus = await singleTideViewModel.createTide(
                byUserID: userId,
                byUsername: username,
                tideTitle: tideTitle,
                tideDescription: tideDescription,
                maxParticipants: participantsCount,
                boundingBox: boundingBox,
                adult: adult,
                category: selectedCategory
            )
            
            // Handle the creation status on the main thread
            await MainActor.run {
                switch creationStatus {
                case .created(let tideId):
                    // Success - dismiss this view and set the lastJoinedTideId to trigger navigation
                    // This uses the same pattern as in AvailableTideListView
                    DispatchQueue.main.async {
                        singleTideViewModel.lastJoinedTideId = tideId
                        dismiss()
                    }
                    
                case .failed:
                    validationMessage = "Failed to create tide. Please try again."
                    showValidationAlert = true
                    
                case .invalidData:
                    validationMessage = "Invalid data provided. Please check your inputs."
                    showValidationAlert = true
                    
                case .missingCredentials:
                    validationMessage = "Missing credentials. Please ensure you're logged in."
                    showValidationAlert = true
                    
                case .missingTideId:
                    validationMessage = "Missing tide ID. Please try again."
                    showValidationAlert = true
                }
            }
        }
    }
}

#Preview {
    CreateTideView()
        .preferredColorScheme(.dark)
}

// Helper extension for placeholder text in TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
