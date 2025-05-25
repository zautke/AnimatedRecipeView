// MARK: - Simple Two-Segment Curved Flow Connector

import SwiftUI

struct IngredientConnection {
    let ingredientIndex: Int
    let instructionIndex: Int
    let confidence: Double
}

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
                context.fill(fillPath, with: .color(instructionColor.opacity(opacity)))
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
