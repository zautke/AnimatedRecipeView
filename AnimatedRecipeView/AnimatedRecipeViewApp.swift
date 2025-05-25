import SwiftUI
internal import Combine

// MARK: - Animation Configuration
@MainActor
class AnimationConfig: ObservableObject {
    
    // Layout Transition Animation
    @Published var layoutResponse: Double = 1.2
    @Published var layoutDamping: Double = 1.0
    @Published var layoutBlendDuration: Double = 0.3
    
    // Content Compression Animation
    @Published var compressionResponse: Double = 0.8
    @Published var compressionDamping: Double = 1.0
    @Published var compressionBlendDuration: Double = 0.2
    
    // Manual Toggle Animation
    @Published var toggleResponse: Double = 1.0
    @Published var toggleDamping: Double = 1.0
    @Published var toggleBlendDuration: Double = 0.3
    
    // Animation timing controls
    @Published var animationDelay: Double = 0.0
    @Published var staggerDelay: Double = 0.05
    
    // Flow connector curve steepness
    @Published var curveApexLength: Double = 30.0
    
    // Computed animations (smooth, no overshoot)
    var layoutAnimation: Animation {
        .spring(response: layoutResponse, dampingFraction: layoutDamping, blendDuration: layoutBlendDuration)
    }
    
    var compressionAnimation: Animation {
        .spring(response: compressionResponse, dampingFraction: compressionDamping, blendDuration: compressionBlendDuration)
    }
    
    var toggleAnimation: Animation {
        .spring(response: toggleResponse, dampingFraction: toggleDamping, blendDuration: toggleBlendDuration)
    }
    
    // Preset configurations (all without springback)
    func loadBouncy() {
        layoutResponse = 0.8; layoutDamping = 0.9
        compressionResponse = 0.6; compressionDamping = 0.9
        curveApexLength = 40.0
    }
    
    func loadSmooth() {
        layoutResponse = 1.4; layoutDamping = 1.0
        compressionResponse = 1.0; compressionDamping = 1.0
        curveApexLength = 25.0
    }
    
    func loadSnappy() {
        layoutResponse = 0.6; layoutDamping = 1.0
        compressionResponse = 0.4; compressionDamping = 1.0
        curveApexLength = 35.0
    }
}

// MARK: - Models and Data
struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    let quantity: String
    let measure: String
    let name: String
}

struct Instruction: Identifiable, Hashable {
    let id = UUID()
    let step: Int
    let description: String
    let duration: String?
}

// MARK: - Connection Analysis
struct IngredientConnection {
    let ingredientIndex: Int
    let instructionIndex: Int
    let confidence: Float // 0.0 to 1.0
}

class ConnectionAnalyzer {
    static func analyzeConnections(ingredients: [Ingredient], instructions: [Instruction]) -> [IngredientConnection] {
        var connections: [IngredientConnection] = []
        
        for (instructionIndex, instruction) in instructions.enumerated() {
            let instructionText = instruction.description.lowercased()
            
            for (ingredientIndex, ingredient) in ingredients.enumerated() {
                let confidence = calculateConfidence(
                    ingredientName: ingredient.name.lowercased(),
                    instructionText: instructionText,
                    instructionStep: instruction.step
                )
                
                if confidence > 0.3 { // Threshold for connection
                    connections.append(IngredientConnection(
                        ingredientIndex: ingredientIndex,
                        instructionIndex: instructionIndex,
                        confidence: confidence
                    ))
                }
            }
        }
        
        return connections
    }
    
    private static func calculateConfidence(ingredientName: String, instructionText: String, instructionStep: Int) -> Float {
        var confidence: Float = 0.0
        
        // Extract key words from ingredient name
        let ingredientWords = ingredientName.components(separatedBy: [" ", ",", "(", ")"]).filter { !$0.isEmpty }
        
        for word in ingredientWords {
            if word.count > 3 { // Skip very short words
                if instructionText.contains(word) {
                    confidence += 0.4
                }
                
                // Check for partial matches
                if instructionText.contains(String(word.prefix(word.count - 1))) {
                    confidence += 0.2
                }
            }
        }
        
        // Special handling for common cooking terms
        let cookingTerms = [
            ("flour", ["mix", "combine", "add", "sift"]),
            ("butter", ["cream", "beat", "mix", "melt"]),
            ("sugar", ["cream", "beat", "mix", "add"]),
            ("eggs", ["beat", "add", "mix"]),
            ("chocolate", ["fold", "add", "melt", "chips"]),
            ("vanilla", ["add", "mix"]),
            ("salt", ["add", "mix", "combine"]),
            ("baking soda", ["mix", "combine", "add"])
        ]
        
        for (ingredient, terms) in cookingTerms {
            if ingredientName.contains(ingredient) {
                for term in terms {
                    if instructionText.contains(term) {
                        confidence += 0.3
                    }
                }
            }
        }
        
        // Early steps more likely to use dry ingredients
        if instructionStep <= 3 && (ingredientName.contains("flour") || ingredientName.contains("salt") || ingredientName.contains("baking")) {
            confidence += 0.2
        }
        
        // Later steps more likely to use chocolate chips, final assembly
        if instructionStep >= 6 && ingredientName.contains("chocolate") {
            confidence += 0.3
        }
        
        return min(confidence, 1.0)
    }
}

struct Recipe {
    let title: String
    let ingredients: [Ingredient]
    let instructions: [Instruction]
    let totalTime: String
    let servings: Int
}

// MARK: - Sample Data
extension Recipe {
    static let chocolateChipCookies = Recipe(
        title: "Ultimate Chocolate Chip Cookies",
        ingredients: [
            Ingredient(quantity: "2¼", measure: "cups", name: "all-purpose flour"),
            Ingredient(quantity: "1", measure: "tsp", name: "baking soda"),
            Ingredient(quantity: "1", measure: "tsp", name: "salt"),
            Ingredient(quantity: "1", measure: "cup", name: "butter, softened"),
            Ingredient(quantity: "¾", measure: "cup", name: "granulated sugar"),
            Ingredient(quantity: "¾", measure: "cup", name: "brown sugar"),
            Ingredient(quantity: "2", measure: "large", name: "eggs"),
            Ingredient(quantity: "2", measure: "tsp", name: "vanilla extract"),
            Ingredient(quantity: "2", measure: "cups", name: "chocolate chips")
        ],
        instructions: [
            Instruction(step: 1, description: "Preheat oven to 375°F (190°C). Line baking sheets with parchment paper.", duration: "2 min"),
            Instruction(step: 2, description: "In a medium bowl, mix flour, baking soda, and salt until well combined.", duration: "3 min"),
            Instruction(step: 3, description: "In a large bowl, cream butter and both sugars until light and fluffy.", duration: "5 min"),
            Instruction(step: 4, description: "Beat in eggs one at a time, then add vanilla extract, mixing well.", duration: "2 min"),
            Instruction(step: 5, description: "Gradually add the flour mixture to the wet ingredients, mixing until just combined.", duration: "3 min"),
            Instruction(step: 6, description: "Fold in chocolate chips, distributing evenly throughout the dough.", duration: "1 min"),
            Instruction(step: 7, description: "Drop rounded tablespoons of dough onto prepared baking sheets, spacing 2 inches apart.", duration: "5 min"),
            Instruction(step: 8, description: "Bake for 9-11 minutes until edges are golden brown but centers still look slightly underbaked.", duration: "10 min")
        ],
        totalTime: "45 min",
        servings: 24
    )
}

// MARK: - Device Type Detection (Swift 6 Compatible)
@MainActor
class DeviceManager: ObservableObject {
    @Published private(set) var deviceType: DeviceType = .unknown
    @Published private(set) var isMultitasking: Bool = false
    
    enum DeviceType {
        case iPhone
        case iPad
        case mac
        case unknown
    }
    
    init() {
        detectDeviceType()
    }
    
    private func detectDeviceType() {
        #if os(iOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        switch idiom {
        case .phone:
            deviceType = .iPhone
        case .pad:
            deviceType = .iPad
        default:
            deviceType = .unknown
        }
        #elseif os(macOS)
        deviceType = .mac
        #else
        deviceType = .unknown
        #endif
    }
    
    func updateMultitaskingState(horizontalSizeClass: UserInterfaceSizeClass?) {
        if deviceType == .iPad {
            isMultitasking = horizontalSizeClass == .compact
        }
    }
}

// MARK: - Orientation Management (Swift 6 Compatible)
@MainActor
class OrientationManager: ObservableObject {
    @Published var isLandscape = false
    
    init() {
        updateOrientation()
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                    self?.updateOrientation()
            }
        }
    }
    
    private func updateOrientation() {
        let orientation = UIDevice.current.orientation
        self.isLandscape = orientation.isLandscape
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Layout State Management
@MainActor
class LayoutManager: ObservableObject {
    @Published var useHorizontalLayout = false
    @Published var useCompactLayout = true
    @Published var isAnimating = false
    
    private let deviceManager: DeviceManager
    private let orientationManager: OrientationManager
    private let animationConfig: AnimationConfig
    
    init(deviceManager: DeviceManager, orientationManager: OrientationManager, animationConfig: AnimationConfig) {
        self.deviceManager = deviceManager
        self.orientationManager = orientationManager
        self.animationConfig = animationConfig
        updateLayout()
    }
    
    func updateLayout(horizontalSizeClass: UserInterfaceSizeClass? = nil) {
        deviceManager.updateMultitaskingState(horizontalSizeClass: horizontalSizeClass)
        
        let shouldUseHorizontal = orientationManager.isLandscape
        let shouldUseCompact = !orientationManager.isLandscape
        
        withAnimation(animationConfig.layoutAnimation) {
            useHorizontalLayout = shouldUseHorizontal
            useCompactLayout = shouldUseCompact
            isAnimating = true
        }
        
        // Reset animation state after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationConfig.layoutResponse + 0.1) {
            self.isAnimating = false
        }
    }
    
    func toggleManualLayout() {
        withAnimation(animationConfig.toggleAnimation) {
            useHorizontalLayout.toggle()
            useCompactLayout.toggle()
            isAnimating = true
        }
        
        // Reset animation state after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationConfig.toggleResponse + 0.1) {
            self.isAnimating = false
        }
    }
}

// MARK: - Enhanced Layout Wrapper with Flow Connectors
struct AnimatedLayoutWrapper<Content: View>: View {
    let useHorizontalLayout: Bool
    let useCompactLayout: Bool
    let isAnimating: Bool
    let deviceType: DeviceManager.DeviceType
    let spacing: CGFloat
    let alignment: Alignment
    let animationConfig: AnimationConfig
    let recipe: Recipe
    @ViewBuilder let content: () -> Content
    
    @State private var ingredientPositions: [Int: CGRect] = [:]
    @State private var instructionPositions: [Int: CGRect] = [:]
    @State private var connections: [IngredientConnection] = []
    
    init(
        useHorizontalLayout: Bool,
        useCompactLayout: Bool,
        isAnimating: Bool,
        deviceType: DeviceManager.DeviceType,
        animationConfig: AnimationConfig,
        recipe: Recipe,
        spacing: CGFloat = 20,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.useHorizontalLayout = useHorizontalLayout
        self.useCompactLayout = useCompactLayout
        self.isAnimating = isAnimating
        self.deviceType = deviceType
        self.animationConfig = animationConfig
        self.recipe = recipe
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        let layout = useHorizontalLayout
            ? AnyLayout(HStackLayout(alignment: verticalAlignment, spacing: spacing))
            : AnyLayout(VStackLayout(alignment: horizontalAlignment, spacing: spacing))
        
        ZStack {
            layout {
                content()
            }
            .coordinateSpace(name: "ConnectionSpace")
            .onPreferenceChange(IngredientPositionPreferenceKey.self) { positions in
                ingredientPositions = positions
            }
            .onPreferenceChange(InstructionPositionPreferenceKey.self) { positions in
                instructionPositions = positions
            }
            
            // Flow connectors - only show in horizontal layout and when not compact
            if useHorizontalLayout && !useCompactLayout {
                FlowConnector(
                    connections: connections,
                    ingredientPositions: ingredientPositions,
                    instructionPositions: instructionPositions,
                    useCompactLayout: useCompactLayout,
                    animationConfig: animationConfig
                )
                .opacity(isAnimating ? 0.3 : 1.0)
            }
        }
        .animation(animationConfig.layoutAnimation, value: useHorizontalLayout)
        .animation(animationConfig.compressionAnimation, value: useCompactLayout)
        .onAppear {
            analyzeConnections()
        }
        .onChange(of: useHorizontalLayout) { _, _ in
            // Re-analyze when layout changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                analyzeConnections()
            }
        }
    }
    
    private func analyzeConnections() {
        connections = ConnectionAnalyzer.analyzeConnections(
            ingredients: recipe.ingredients,
            instructions: recipe.instructions
        )
    }
    
    private var verticalAlignment: VerticalAlignment {
        switch alignment {
        case .top: return .top
        case .bottom: return .bottom
        default: return .center
        }
    }
    
    private var horizontalAlignment: HorizontalAlignment {
        switch alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }
}

// MARK: - Gradient Header Component
struct GradientHeader: View {
    let title: String
    let color: Color
    let useCompactLayout: Bool
    let animationConfig: AnimationConfig
    
    var body: some View {
        HStack {
            Text(title)
                .font(useCompactLayout ? .headline : .title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, useCompactLayout ? 12 : 16)
        .background(
            LinearGradient(
                stops: [
                    .init(color: color.opacity(0.8), location: 0.0),
                    .init(color: color.opacity(0.4), location: 0.3),
                    .init(color: color.opacity(0.1), location: 0.7),
                    .init(color: color.opacity(0.0), location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .animation(animationConfig.compressionAnimation, value: useCompactLayout)
    }
}

// MARK: - Enhanced Section Views
struct IngredientsSection: View {
    let ingredients: [Ingredient]
    let useCompactLayout: Bool
    let deviceType: DeviceManager.DeviceType
    let animationConfig: AnimationConfig
    let showConnectors: Bool
    let connections: [IngredientConnection]
    
    private var fontSize: Font {
        switch deviceType {
        case .iPhone:
            return useCompactLayout ? .caption : .body
        case .iPad, .mac:
            return useCompactLayout ? .body : .title3
        case .unknown:
            return .body
        }
    }
    
    private var lineSpacing: CGFloat {
        useCompactLayout ? 2 : 8
    }
    
    private var columns: [GridItem] {
        if useCompactLayout || !showConnectors {
            return [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ]
        } else {
            return [GridItem(.flexible())]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GradientHeader(
                title: "Ingredients",
                color: .orange,
                useCompactLayout: useCompactLayout,
                animationConfig: animationConfig
            )
            
            LazyVGrid(columns: columns, spacing: lineSpacing) {
                ForEach(Array(ingredients.enumerated()), id: \.element.id) { index, ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        fontSize: fontSize,
                        useCompactLayout: useCompactLayout,
                        animationConfig: animationConfig,
                        index: index,
                        connectionColors: showConnectors ? ConnectionColorCalculator.getConnectionColors(for: index, connections: connections) : []
                    )
                    .animation(
                        animationConfig.compressionAnimation.delay(Double(index) * animationConfig.staggerDelay),
                        value: useCompactLayout
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

struct InstructionsSection: View {
    let instructions: [Instruction]
    let useCompactLayout: Bool
    let deviceType: DeviceManager.DeviceType
    let animationConfig: AnimationConfig
    let showConnectors: Bool
    
    private var fontSize: Font {
        switch deviceType {
        case .iPhone:
            return useCompactLayout ? .caption : .body
        case .iPad, .mac:
            return useCompactLayout ? .body : .title3
        case .unknown:
            return .body
        }
    }
    
    private var lineSpacing: CGFloat {
        useCompactLayout ? 2 : 12
    }
    
    private var columns: [GridItem] {
        if useCompactLayout || !showConnectors {
            return [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ]
        } else {
            return [GridItem(.flexible())]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GradientHeader(
                title: "Instructions",
                color: .blue,
                useCompactLayout: useCompactLayout,
                animationConfig: animationConfig
            )
            
            LazyVGrid(columns: columns, spacing: lineSpacing) {
                ForEach(Array(instructions.enumerated()), id: \.element.id) { index, instruction in
                    InstructionRow(
                        instruction: instruction,
                        fontSize: fontSize,
                        useCompactLayout: useCompactLayout,
                        animationConfig: animationConfig,
                        index: index
                    )
                    .animation(
                        animationConfig.compressionAnimation.delay(Double(index) * animationConfig.staggerDelay),
                        value: useCompactLayout
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Enhanced Row Components with Uniform Flow Backgrounds
struct IngredientRow: View {
    let ingredient: Ingredient
    let fontSize: Font
    let useCompactLayout: Bool
    let animationConfig: AnimationConfig
    let index: Int
    let connectionColors: [Color]
    
    var body: some View {
        HStack(spacing: 0) {
            Text(ingredient.quantity)
                .font(fontSize)
                .frame(width: useCompactLayout ? 24 : 32, alignment: .trailing)
            
            Text(ingredient.measure)
                .font(fontSize)
                .frame(width: useCompactLayout ? 40 : 56, alignment: .leading)
                .padding(.leading, 4)
            
            Text(ingredient.name)
                .font(fontSize)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
        }
        .padding(.vertical, useCompactLayout ? 2 : 6)
        .padding(.horizontal, 12)
        .background(
            GeometryReader { geometry in
                ZStack {
                    // Uniform color background for connected ingredients
                    if !connectionColors.isEmpty {
                        // Use the primary connection color
                        Rectangle()
                            .fill(connectionColors.first?.opacity(0.3) ?? Color.clear)
                    }
                    
                    Color.clear.preference(key: IngredientPositionPreferenceKey.self,
                                         value: [index: geometry.frame(in: .named("ConnectionSpace"))])
                }
            }
        )
        .contentShape(Rectangle())
        .animation(animationConfig.compressionAnimation, value: useCompactLayout)
    }
}

struct InstructionRow: View {
    let instruction: Instruction
    let fontSize: Font
    let useCompactLayout: Bool
    let animationConfig: AnimationConfig
    let index: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: useCompactLayout ? 6 : 12) {
            Text("\(instruction.step)")
                .font(fontSize)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .frame(width: useCompactLayout ? 18 : 24, height: useCompactLayout ? 18 : 24)
                .background(Circle().fill(instructionColor(for: instruction.step)))
            
            VStack(alignment: .leading, spacing: useCompactLayout ? 2 : 4) {
                Text(instruction.description)
                    .font(fontSize)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let duration = instruction.duration, !useCompactLayout {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(duration)
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, useCompactLayout ? 2 : 6)
        .padding(.horizontal, 12)
        .background(
            GeometryReader { geometry in
                ZStack {
                    // Uniform color background for instruction step
                    Rectangle()
                        .fill(instructionColor(for: instruction.step).opacity(0.3))
                    
                    Color.clear.preference(key: InstructionPositionPreferenceKey.self,
                                         value: [index: geometry.frame(in: .named("ConnectionSpace"))])
                }
            }
        )
        .contentShape(Rectangle())
        .animation(animationConfig.compressionAnimation, value: useCompactLayout)
    }
    
    private func instructionColor(for step: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .cyan, .mint, .pink, .indigo, .teal]
        return colors[(step - 1) % colors.count]
    }
}

// MARK: - Connection Color Calculator
class ConnectionColorCalculator {
    static func getConnectionColors(for ingredientIndex: Int, connections: [IngredientConnection]) -> [Color] {
        let relevantConnections = connections.filter { $0.ingredientIndex == ingredientIndex }
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .cyan, .mint, .pink, .indigo, .teal]
        
        return relevantConnections.map { connection in
            colors[connection.instructionIndex % colors.count]
        }
    }
    
    static func getInstructionColor(for step: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .cyan, .mint, .pink, .indigo, .teal]
        return colors[(step - 1) % colors.count]
    }
}

// MARK: - Preference Keys for Positioning
struct IngredientPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

struct InstructionPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Simple Two-Segment Curved Flow Connector
struct FlowConnector: View {
    let connections: [IngredientConnection]
    let ingredientPositions: [Int: CGRect]
    let instructionPositions: [Int: CGRect]
    let useCompactLayout: Bool
    let animationConfig: AnimationConfig
    
    var body: some View {
        Canvas { context, size in
            for connection in connections {
                guard let ingredientRect = ingredientPositions[connection.ingredientIndex],
                      let instructionRect = instructionPositions[connection.instructionIndex] else { continue }
                
                let instructionColor = getInstructionColor(for: connection.instructionIndex + 1)
                let opacity = Double(connection.confidence) * 0.4 + 0.4 // Ensure visibility with transparency
                
                // Calculate corner points
                let topStartPoint = CGPoint(x: ingredientRect.maxX, y: ingredientRect.minY)
                let topEndPoint = CGPoint(x: instructionRect.minX, y: instructionRect.minY)
                let bottomStartPoint = CGPoint(x: ingredientRect.maxX, y: ingredientRect.maxY)
                let bottomEndPoint = CGPoint(x: instructionRect.minX, y: instructionRect.maxY)
                
                // Create filled shape between top and bottom curves
                let fillPath = createFlowShape(
                    topStart: topStartPoint,
                    topEnd: topEndPoint,
                    bottomStart: bottomStartPoint,
                    bottomEnd: bottomEndPoint
                )
                
                // Draw filled flow area with uniform color and transparency
                context.drawPath(fillPath, with: .color(instructionColor.opacity(opacity)))
            }
        }
        .allowsHitTesting(false)
        .animation(animationConfig.layoutAnimation, value: useCompactLayout)
    }
    
    private func createFlowShape(topStart: CGPoint, topEnd: CGPoint, bottomStart: CGPoint, bottomEnd: CGPoint) -> Path {
        var path = Path()
        
        let curveApexLength = CGFloat(animationConfig.curveApexLength)
        
        // Start at top-left of ingredient
        path.move(to: topStart)
        
        // Top curve to instruction
        let topMidPoint = CGPoint(
            x: topStart.x + (topEnd.x - topStart.x) / 2,
            y: topStart.y + (topEnd.y - topStart.y) / 2
        )
        let topApex = CGPoint(
            x: topMidPoint.x,
            y: topMidPoint.y - curveApexLength
        )
        
        path.addQuadCurve(to: topMidPoint, control: topApex)
        path.addQuadCurve(to: topEnd, control: topApex)
        
        // Right edge of instruction (connect top to bottom)
        path.addLine(to: bottomEnd)
        
        // Bottom curve back to ingredient (reversed)
        let bottomMidPoint = CGPoint(
            x: bottomStart.x + (bottomEnd.x - bottomStart.x) / 2,
            y: bottomStart.y + (bottomEnd.y - bottomStart.y) / 2
        )
        let bottomApex = CGPoint(
            x: bottomMidPoint.x,
            y: bottomMidPoint.y + curveApexLength
        )
        
        path.addQuadCurve(to: bottomMidPoint, control: bottomApex)
        path.addQuadCurve(to: bottomStart, control: bottomApex)
        
        // Close the shape
        path.closeSubpath()
        
        return path
    }
    
    private func getInstructionColor(for step: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .cyan, .mint, .pink, .indigo, .teal]
        return colors[(step - 1) % colors.count]
    }
}

// MARK: - Layout Toggle Button
struct LayoutToggleButton: View {
    let useHorizontalLayout: Bool
    let animationConfig: AnimationConfig
    let action: () -> Void
    
    private var iconName: String {
        useHorizontalLayout ? "rectangle.split.2x1" : "rectangle.split.1x2"
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(animationConfig.toggleAnimation, value: useHorizontalLayout)
    }
}

// MARK: - Recipe Header
struct RecipeHeader: View {
    let recipe: Recipe
    let deviceType: DeviceManager.DeviceType
    let useCompactLayout: Bool
    let animationConfig: AnimationConfig
    
    private var titleFont: Font {
        switch deviceType {
        case .iPhone:
            return useCompactLayout ? .title3 : .title2
        case .iPad, .mac:
            return useCompactLayout ? .title : .largeTitle
        case .unknown:
            return .title
        }
    }
    
    private var subtitleFont: Font {
        switch deviceType {
        case .iPhone:
            return useCompactLayout ? .caption2 : .caption
        case .iPad, .mac:
            return useCompactLayout ? .footnote : .subheadline
        case .unknown:
            return .footnote
        }
    }
    
    var body: some View {
        VStack(spacing: useCompactLayout ? 8 : 12) {
            Text(recipe.title)
                .font(titleFont)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            if !useCompactLayout {
                HStack(spacing: 24) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text(recipe.totalTime)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.blue)
                        Text("\(recipe.servings) servings")
                            .fontWeight(.medium)
                    }
                }
                .font(subtitleFont)
                .foregroundColor(.secondary)
            }
        }
        .padding(useCompactLayout ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .animation(animationConfig.compressionAnimation, value: useCompactLayout)
    }
}

// MARK: - Animation Controls Panel
struct AnimationControlsPanel: View {
    @ObservedObject var animationConfig: AnimationConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎛️ Animation Controls")
                .font(.headline)
                .fontWeight(.bold)
            
            // Preset buttons
            HStack(spacing: 12) {
                Button("Bouncy") { animationConfig.loadBouncy() }
                Button("Smooth") { animationConfig.loadSmooth() }
                Button("Snappy") { animationConfig.loadSnappy() }
            }
            .buttonStyle(.bordered)
            
            // Layout Animation
            GroupBox("Layout Transition") {
                VStack(spacing: 8) {
                    SliderControl(value: $animationConfig.layoutResponse, range: 0.1...2.0, label: "Response", format: "%.2f")
                    SliderControl(value: $animationConfig.layoutDamping, range: 0.1...1.0, label: "Damping", format: "%.2f")
                    SliderControl(value: $animationConfig.layoutBlendDuration, range: 0.0...1.0, label: "Blend", format: "%.2f")
                }
            }
            
            // Content Compression
            GroupBox("Content Compression") {
                VStack(spacing: 8) {
                    SliderControl(value: $animationConfig.compressionResponse, range: 0.1...2.0, label: "Response", format: "%.2f")
                    SliderControl(value: $animationConfig.compressionDamping, range: 0.1...1.0, label: "Damping", format: "%.2f")
                    SliderControl(value: $animationConfig.staggerDelay, range: 0.0...0.2, label: "Stagger", format: "%.3f")
                }
            }
            
            // Flow Curve Controls
            GroupBox("🌊 Flow Curve Steepness") {
                VStack(spacing: 8) {
                    SliderControl(value: $animationConfig.curveApexLength, range: 5.0...80.0, label: "Curve", format: "%.0f")
                    Text("Adjusts how pronounced the curve bends")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SliderControl: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let label: String
    let format: String
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 70, alignment: .leading)
                .font(.caption)
            
            Slider(value: $value, in: range)
            
            Text(String(format: format, value))
                .frame(width: 40, alignment: .trailing)
                .font(.caption.monospacedDigit())
        }
    }
}

// MARK: - Interactive Prototype View
struct InteractivePrototypeView: View {
    let recipe = Recipe.chocolateChipCookies
    
    @StateObject private var animationConfig = AnimationConfig()
    @StateObject private var deviceManager = DeviceManager()
    @StateObject private var orientationManager = OrientationManager()
    @StateObject private var layoutManager: LayoutManager
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init() {
        let animConfig = AnimationConfig()
        let deviceMgr = DeviceManager()
        let orientationMgr = OrientationManager()
        
        self._animationConfig = StateObject(wrappedValue: animConfig)
        self._deviceManager = StateObject(wrappedValue: deviceMgr)
        self._orientationManager = StateObject(wrappedValue: orientationMgr)
        self._layoutManager = StateObject(wrappedValue: LayoutManager(
            deviceManager: deviceMgr,
            orientationManager: orientationMgr,
            animationConfig: animConfig
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Animation Controls
                    AnimationControlsPanel(animationConfig: animationConfig)
                    
                    // Recipe Header
                    RecipeHeader(
                        recipe: recipe,
                        deviceType: deviceManager.deviceType,
                        useCompactLayout: layoutManager.useCompactLayout,
                        animationConfig: animationConfig
                    )
                    
                    // Animated Layout Wrapper with Recipe Content
                    AnimatedLayoutWrapper(
                        useHorizontalLayout: layoutManager.useHorizontalLayout,
                        useCompactLayout: layoutManager.useCompactLayout,
                        isAnimating: layoutManager.isAnimating,
                        deviceType: deviceManager.deviceType,
                        animationConfig: animationConfig,
                        recipe: recipe,
                        spacing: 24,
                        alignment: .top
                    ) {
                        IngredientsSection(
                            ingredients: recipe.ingredients,
                            useCompactLayout: layoutManager.useCompactLayout,
                            deviceType: deviceManager.deviceType,
                            animationConfig: animationConfig,
                            showConnectors: layoutManager.useHorizontalLayout && !layoutManager.useCompactLayout,
                            connections: connections
                        )
                        .layoutPriority(1)
                        
                        InstructionsSection(
                            instructions: recipe.instructions,
                            useCompactLayout: layoutManager.useCompactLayout,
                            deviceType: deviceManager.deviceType,
                            animationConfig: animationConfig,
                            showConnectors: layoutManager.useHorizontalLayout && !layoutManager.useCompactLayout
                        )
                        .layoutPriority(1)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground).opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("🎛️ Animation Prototype")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LayoutToggleButton(
                        useHorizontalLayout: layoutManager.useHorizontalLayout,
                        animationConfig: animationConfig
                    ) {
                        layoutManager.toggleManualLayout()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for proper iPad behavior
        .onChange(of: horizontalSizeClass) { _, newValue in
            layoutManager.updateLayout(horizontalSizeClass: newValue)
        }
        .onChange(of: orientationManager.isLandscape) { _, _ in
            layoutManager.updateLayout(horizontalSizeClass: horizontalSizeClass)
        }
        .onAppear {
            layoutManager.updateLayout(horizontalSizeClass: horizontalSizeClass)
        }
    }
}

// MARK: - Main Recipe View (Clean Production Version)
struct AnimatedRecipeWrapper: View {
    let recipe = Recipe.chocolateChipCookies
    
    @StateObject private var animationConfig = AnimationConfig()
    @StateObject private var deviceManager = DeviceManager()
    @StateObject private var orientationManager = OrientationManager()
    @StateObject private var layoutManager: LayoutManager
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init() {
        let animConfig = AnimationConfig()
        let deviceMgr = DeviceManager()
        let orientationMgr = OrientationManager()
        
        self._animationConfig = StateObject(wrappedValue: animConfig)
        self._deviceManager = StateObject(wrappedValue: deviceMgr)
        self._orientationManager = StateObject(wrappedValue: orientationMgr)
        self._layoutManager = StateObject(wrappedValue: LayoutManager(
            deviceManager: deviceMgr,
            orientationManager: orientationMgr,
            animationConfig: animConfig
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    RecipeHeader(
                        recipe: recipe,
                        deviceType: deviceManager.deviceType,
                        useCompactLayout: layoutManager.useCompactLayout,
                        animationConfig: animationConfig
                    )
                    
                    AnimatedLayoutWrapper(
                        useHorizontalLayout: layoutManager.useHorizontalLayout,
                        useCompactLayout: layoutManager.useCompactLayout,
                        isAnimating: layoutManager.isAnimating,
                        deviceType: deviceManager.deviceType,
                        animationConfig: animationConfig,
                        recipe: recipe,
                        spacing: 24,
                        alignment: .top
                    ) {
                        IngredientsSection(
                            ingredients: recipe.ingredients,
                            useCompactLayout: layoutManager.useCompactLayout,
                            deviceType: deviceManager.deviceType,
                            animationConfig: animationConfig,
                            showConnectors: layoutManager.useHorizontalLayout && !layoutManager.useCompactLayout,
                            connections: connections
                        )
                        .layoutPriority(1)
                        
                        InstructionsSection(
                            instructions: recipe.instructions,
                            useCompactLayout: layoutManager.useCompactLayout,
                            deviceType: deviceManager.deviceType,
                            animationConfig: animationConfig,
                            showConnectors: layoutManager.useHorizontalLayout && !layoutManager.useCompactLayout
                        )
                        .layoutPriority(1)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground).opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LayoutToggleButton(
                        useHorizontalLayout: layoutManager.useHorizontalLayout,
                        animationConfig: animationConfig
                    ) {
                        layoutManager.toggleManualLayout()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for proper iPad behavior
        .onChange(of: horizontalSizeClass) { _, newValue in
            layoutManager.updateLayout(horizontalSizeClass: newValue)
        }
        .onChange(of: orientationManager.isLandscape) { _, _ in
            layoutManager.updateLayout(horizontalSizeClass: horizontalSizeClass)
        }
        .onAppear {
            layoutManager.updateLayout(horizontalSizeClass: horizontalSizeClass)
        }
    }
}

// MARK: - Preview
#Preview("🎛️ Interactive Animation Prototype") {
    InteractivePrototypeView()
}

#Preview("📱 iPhone Portrait") {
    AnimatedRecipeWrapper()
}

#Preview("📱 iPhone Landscape") {
    AnimatedRecipeWrapper()
}

#Preview("📱 iPad Portrait") {
    AnimatedRecipeWrapper()
}

// MARK: - App Entry Point
@main
struct RecipeApp: App {
    var body: some Scene {
        WindowGroup {
            InteractivePrototypeView()
        }
    }
}
