//
//  TemplateManager.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/2/25.
//

import SwiftUI

struct TemplateManager {
    static let shared = TemplateManager()
    
    
    // Predefined Templates
    var templates: [Template] { generateDynamicTemplates() + [
        
        Template(
            id: 110,
            name: "Freeform",
            type: .freeform,
            layout: [] // No predefined layout
        ),
        // Vertical Strips
        Template(
            id: 101,
            name: "Vertical Strips",
            type: .mosaic,
            layout: (0..<4).map { index in
                CGRect(
                    x: CGFloat(index) * 0.25,
                    y: 0,
                    width: 0.25,
                    height: 1.0
                )
            }
        ),
        
        // Horizontal Strips
        Template(
            id: 102,
            name: "Horizontal Strips",
            type: .mosaic,
            layout: (0..<4).map { index in
                CGRect(
                    x: 0,
                    y: CGFloat(index) * 0.25,
                    width: 1.0,
                    height: 0.25
                )
            }
        ),
        
        // Star Shape (Custom Implementation Needed for Shape)
        Template(
            id: 103,
            name: "Star",
            type: .customShape("Star"),
            layout: [] // Use a custom shape logic
        ),
        
        // Triangle Layout
//        Template(
//            id: 104,
//            name: "Triangle",
//            type: .customShape("Triangle"),
//            layout: [] // Use a triangle shape logic
//        ),
        
        // Other Custom Layouts
        Template(
            id: 105,
            name: "Diamond",
            type: .customShape("Diamond"),
            layout: [] // Diamond logic
        ),
        
        Template(
            id: 106,
            name: "L-shape",
            type: .mosaic,
            layout: [
                CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.25),
                CGRect(x: 0.5, y: 0.25, width: 0.25, height: 0.25)
            ]
        ),
        
        Template(
            id: 107,
            name: "Cross",
            type: .mosaic,
            layout: [
                CGRect(x: 0.4, y: 0, width: 0.2, height: 1.0),
                CGRect(x: 0, y: 0.4, width: 1.0, height: 0.2)
            ]
        ),
        
        
        Template(
            id: 108,
            name: "Circle",
            type: .circle,
            layout: []
        ),
        Template(
            id: 109,
            name: "Mosaic",
            type: .mosaic,
            layout: [
                CGRect(x: 0, y: 0, width: 0.6, height: 0.4),
                CGRect(x: 0.6, y: 0, width: 0.4, height: 0.4),
                CGRect(x: 0, y: 0.4, width: 0.4, height: 0.6),
                CGRect(x: 0.4, y: 0.4, width: 0.6, height: 0.6)
            ]
        ),
        
        // Heart Shape
        Template(
            id: 201,
            name: "Heart",
            type: .customShape("Heart"),
            layout: [] // Adjust number of images as needed
        ),
        
        // Flower Shape
        Template(
            id: 202,
            name: "Flower",
            type: .customShape("Flower"),
            layout: [] // Adjust number of petals as needed
        ),
        
//        // Starburst Layout
//        Template(
//            id: 203,
//            name: "Starburst",
//            type: .customShape("Starburst"),
//            layout: generateStarburstLayout(for: 10) // Adjust number of rays as needed
//        ),
//        
//        // Wave Layout
//        Template(
//            id: 204,
//            name: "Wave",
//            type: .customShape("Wave"),
//            layout: generateWaveLayout(for: 10) // Adjust number of waves as needed
//        ),
//        Template(
//            id: 205,
//            name: "Hexagon",
//            type: .customShape("Hexagon"),
//            layout: createHexagonLayout()
//        ),
//        Template(
//            id: 206,
//            name: "Arrow",
//            type: .customShape("Arrow"),
//            layout: createArrowLayout()
//        ),
//        Template(
//            id: 207,
//            name: "Zigzag",
//            type: .customShape("Zigzag"),
//            layout: createZigzagLayout()
//        ),
//        Template(
//            id: 208,
//            name: "Ladder",
//            type: .customShape("Ladder"),
//            layout: createLadderLayout()
//        ),
//        Template(
//            id: 209,
//            name: "Diamond Grid",
//            type: .customShape("Diamond Grid"),
//            layout: createDiamondGridLayout()
//        ),
        Template(
            id: 210,
            name: "Spiral",
            type: .customShape("Spiral"),
            layout: []
        ),
//        Template(
//            id: 211,
//            name: "Checkerboard",
//            type: .customShape("Checkerboard"),
//            layout: createCheckerboardLayout()
//        ),
//        Template(
//            id: 212,
//            name: "Infinity",
//            type: .customShape("Infinity"),
//            layout: createInfinityLayout()
       // )
    ]
    }
    
    
    // Generate dynamic templates programmatically
    func generateDynamicTemplates() -> [Template] {
        var dynamicTemplates: [Template] = []
        for i in 2...10 { // Grid templates with varying sizes
            let layout = (0..<(i * i)).map { index in
                CGRect(
                    x: CGFloat(index % i) * (1.0 / CGFloat(i)),
                    y: CGFloat(index / i) * (1.0 / CGFloat(i)),
                    width: 1.0 / CGFloat(i),
                    height: 1.0 / CGFloat(i)
                )
            }
            dynamicTemplates.append(
                Template(
                    id: i,
                    name: "Grid \(i)x\(i)",
                    type: .grid(rows:i, columns: i),
                    layout: layout
                )
            )
        }
        return dynamicTemplates
    }
    
//    func createHexagonLayout() -> [CGRect] {
//        var layout: [CGRect] = []
//        for i in 0..<6 {
//            let angle = Double(i) * .pi / 3
//            let x = 0.5 + 0.3 * cos(angle)
//            let y = 0.5 - 0.3 * sin(angle)
//            layout.append(CGRect(x: x - 0.05, y: y - 0.05, width: 0.1, height: 0.1))
//        }
//        return layout
//    }
//    
//    func createArrowLayout() -> [CGRect] {
//        return [
//            CGRect(x: 0.4, y: 0.1, width: 0.2, height: 0.3),
//            CGRect(x: 0.3, y: 0.4, width: 0.4, height: 0.2),
//            CGRect(x: 0.45, y: 0.6, width: 0.1, height: 0.3)
//        ]
//    }
//    
//    func createZigzagLayout() -> [CGRect] {
//        var layout: [CGRect] = []
//        for i in 0..<5 {
//            let x = Double(i % 2) * 0.4
//            let y = Double(i) * 0.2
//            layout.append(CGRect(x: x, y: y, width: 0.2, height: 0.1))
//        }
//        return layout
//    }
//    
//    func createLadderLayout() -> [CGRect] {
//        var layout: [CGRect] = []
//        for i in 0..<6 {
//            let x = Double(i % 2) * 0.4
//            let y = Double(i) * 0.15
//            layout.append(CGRect(x: x, y: y, width: 0.2, height: 0.1))
//        }
//        return layout
//    }
//    
//    func createDiamondGridLayout() -> [CGRect] {
//        var layout: [CGRect] = []
//        let positions = [
//            CGPoint(x: 0.5, y: 0.3), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.5, y: 0.7)
//        ]
//        for pos in positions {
//            layout.append(CGRect(x: pos.x - 0.05, y: pos.y - 0.05, width: 0.1, height: 0.1))
//        }
//        return layout
//    }
    
    func createSpiralLayout(for count: Int, in canvasSize: CGSize) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let baseRadius = min(canvasSize.width, canvasSize.height) / 10
        var frames: [CGRect] = []
        
        for i in 0..<count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count))
            let radius = baseRadius + CGFloat(i) * 10
            let x = center.x + radius * cos(angle) - 50
            let y = center.y + radius * sin(angle) - 50
            
            frames.append(CGRect(x: x, y: y, width: 100, height: 100))
        }
        
        return frames
    }
    
    
    // Generate Heart Layout
    func createHeartLayout(for count: Int, in canvasSize: CGSize) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let radius = min(canvasSize.width, canvasSize.height) / 3
        var frames: [CGRect] = []
        
        for i in 0..<count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count))
            let x = center.x + radius * sin(angle) * abs(sin(angle)) - 50
            let y = center.y - radius * cos(angle) * abs(cos(angle)) - 50
            
            frames.append(CGRect(x: x, y: y, width: 100, height: 100)) // Adjust size dynamically if needed
        }
        
        return frames
    }
    
//    func createCheckerboardLayout() -> [CGRect] {
//        var layout: [CGRect] = []
//        for row in 0..<4 {
//            for col in 0..<4 where (row + col) % 2 == 0 {
//                layout.append(CGRect(x: CGFloat(col) * 0.25, y: CGFloat(row) * 0.25, width: 0.25, height: 0.25))
//            }
//        }
//        return layout
//    }
//    
//    func createInfinityLayout() -> [CGRect] {
//        var layout: [CGRect] = []
//        for i in 0..<10 {
//            let t = Double(i) * .pi / 5
//            let x = 0.5 + 0.3 * sin(t)
//            let y = 0.5 + 0.2 * sin(2 * t)
//            layout.append(CGRect(x: x - 0.05, y: y - 0.05, width: 0.1, height: 0.1))
//        }
//        return layout
//    }
    
    // Generate Flower Layout
    func createFlowerLayout(for count: Int, in canvasSize: CGSize) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let radius = min(canvasSize.width, canvasSize.height) / 3
        var frames: [CGRect] = []
        
        for i in 0..<count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count))
            let x = center.x + radius * cos(angle) - 50
            let y = center.y + radius * sin(angle) - 50
            
            frames.append(CGRect(x: x, y: y, width: 100, height: 100))
        }
        
        return frames
    }
    
    // Generate Starburst Layout
//    func generateStarburstLayout(for rayCount: Int) -> [CGRect] {
//        var layout: [CGRect] = []
//        let center = CGPoint(x: 0.5, y: 0.5)
//        
//        for i in 0..<rayCount {
//            let angle = CGFloat(i) * (.pi * 2) / CGFloat(rayCount)
//            let x = center.x + 0.4 * cos(angle)
//            let y = center.y + 0.4 * sin(angle)
//            
//            layout.append(CGRect(x: x - 0.05, y: y - 0.05, width: 0.1, height: 0.1))
//        }
//        
//        layout.append(CGRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1)) // Center circle
//        return layout
//    }
//    
//    // Generate Wave Layout
//    func generateWaveLayout(for count: Int) -> [CGRect] {
//        var layout: [CGRect] = []
//        let amplitude: CGFloat = 0.1
//        
//        for i in 0..<count {
//            let t = CGFloat(i) / CGFloat(count - 1)
//            let x = t
//            let y = 0.5 + amplitude * sin(t * .pi * 4)
//            
//            layout.append(CGRect(x: x - 0.05, y: y - 0.05, width: 0.1, height: 0.1))
//        }
//        return layout
//    }
//    
    
    func starLayout(for count: Int, in canvasSize: CGSize) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let radius = min(canvasSize.width, canvasSize.height) / 3
        var frames: [CGRect] = []
        
        for i in 0..<count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count))
            let x = center.x + radius * cos(angle) - 50 // Adjust for size
            let y = center.y + radius * sin(angle) - 50
            
            frames.append(CGRect(x: x, y: y, width: 100, height: 100)) // Default size 100x100
        }
        
        return frames
    }
    
    func triangleLayout(for count: Int, in canvasSize: CGSize) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let baseY = canvasSize.height * 0.75
        let topY = canvasSize.height * 0.25
        let centerX = canvasSize.width / 2
        var frames: [CGRect] = []
        
        for i in 0..<count {
            let x = centerX + CGFloat(i - count / 2) * 100 // Adjust for spacing
            let y = (i % 2 == 0) ? topY : baseY // Alternate top and base positions
            
            frames.append(CGRect(x: x, y: y, width: 100, height: 100))
        }
        
        return frames
    }
    
    func diamondLayout(for count: Int, in canvasSize: CGSize) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let size = min(canvasSize.width, canvasSize.height) / CGFloat(max(count, 4))
        var frames: [CGRect] = []
        
        // Top half of the diamond
        for i in 0..<((count + 1) / 2) {
            let offset = CGFloat(i) * size
            let width = size
            let height = size
            frames.append(CGRect(x: center.x - offset - (width / 2), y: center.y - offset - (height / 2), width: width, height: height))
            if i > 0 {
                frames.append(CGRect(x: center.x + offset - (width / 2), y: center.y - offset - (height / 2), width: width, height: height))
            }
        }
        
        // Bottom half of the diamond
        for i in 1..<((count + 1) / 2) {
            let offset = CGFloat(i) * size
            let width = size
            let height = size
            frames.append(CGRect(x: center.x - offset - (width / 2), y: center.y + offset - (height / 2), width: width, height: height))
            frames.append(CGRect(x: center.x + offset - (width / 2), y: center.y + offset - (height / 2), width: width, height: height))
        }
        
        return Array(frames.prefix(count)) // Trim extra frames if count is less than calculated positions
    }
    
    
    
    
    // Dynamic Layout for Circular Templates
    func circularLayout(for count: Int, in canvasSize: CGSize, radiusScale: CGFloat = 1.0) -> [CGRect] {
        guard count > 0 else { return [] }
        
        let baseRadius = min(canvasSize.width, canvasSize.height) / 3
        let radius = baseRadius * radiusScale // Apply scale factor to radius
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let circleSize = radius / 3 // Adjust size of images relative to radius
        var frames: [CGRect] = []
        
        for i in 0..<count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count))
            let x = center.x + radius * cos(angle) - (circleSize / 2)
            let y = center.y + radius * sin(angle) - (circleSize / 2)
            
            frames.append(CGRect(x: x, y: y, width: circleSize, height: circleSize))
        }
        
        return frames
    }
    
    
    
}

struct Template: Identifiable {
    let id:Int
    let name: String
    let type: TemplateType
    let layout: [CGRect]
}

enum TemplateType:Equatable {
    case grid(rows: Int, columns:Int)
    case freeform
    case circle
    case mosaic
    case customShape(String)
}

