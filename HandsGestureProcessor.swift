
//
//  HandsGestureProcessor.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//


import SwiftUI
import Vision

class HandGestureProcessor: ObservableObject {
    @Published var leftHandPoints: [CGPoint] = []
    @Published var rightHandPoints: [CGPoint] = []
    
    var detectedHandChiralities: [VNChirality] = []
    
    @Published private(set) var isLeftHandDetected: Bool = false
    @Published private(set) var isRightHandDetected: Bool = false
    
    @Published var leftPinchDistance: CGFloat = 0
    @Published var rightPinchDistance: CGFloat = 0
    
    @Published var isLeftPinching: Bool = false
    @Published var isRightPinching: Bool = false
    
    let minDistance: CGFloat = 20
    let maxDistance: CGFloat = 120
    
    private let smoothingBufferSize = 5
    private var leftDistanceBuffer: [CGFloat] = []
    private var rightDistanceBuffer: [CGFloat] = []
    
    private let pinchMaxDistance: CGFloat = 20
    
    private let evidenceCounterStateTrigger = 3
    
    private enum PinchState {
        case unknown
        case possiblePinch
        case pinched
        case possibleApart
        case apart
    }
    
    private var leftPinchState: PinchState = .unknown
    private var rightPinchState: PinchState = .unknown
    
    private var leftPinchEvidence = 0
    private var leftApartEvidence = 0
    
    private var rightPinchEvidence = 0
    private var rightApartEvidence = 0
    
    
  
    func updateHandPoints(_ allPoints: [[CGPoint]], chiralities: [VNChirality]) {
        detectedHandChiralities = chiralities
        
        isLeftHandDetected = chiralities.contains(.left)
        isRightHandDetected = chiralities.contains(.right)
        
        leftHandPoints = []
        rightHandPoints = []
        
        for (index, points) in allPoints.enumerated() {
            if index < chiralities.count {
                if chiralities[index] == .left {
                    leftHandPoints = points
                } else if chiralities[index] == .right {
                    rightHandPoints = points
                }
            }
        }
        
        let rawLeftDistance = computePinchDistance(leftHandPoints)
        let rawRightDistance = computePinchDistance(rightHandPoints)
        
        leftDistanceBuffer.append(rawLeftDistance)
        if leftDistanceBuffer.count > smoothingBufferSize {
            leftDistanceBuffer.removeFirst()
        }
        leftPinchDistance = leftDistanceBuffer.reduce(0, +) / CGFloat(max(1, leftDistanceBuffer.count))
        
        rightDistanceBuffer.append(rawRightDistance)
        if rightDistanceBuffer.count > smoothingBufferSize {
            rightDistanceBuffer.removeFirst()
        }
        rightPinchDistance = rightDistanceBuffer.reduce(0, +) / CGFloat(max(1, rightDistanceBuffer.count))
        
        updatePinchState(forLeftHand: true, distance: leftPinchDistance)
        updatePinchState(forLeftHand: false, distance: rightPinchDistance)
    }
    
    private func updatePinchState(forLeftHand: Bool, distance: CGFloat) {
        if forLeftHand {
            if distance > pinchMaxDistance {
                leftPinchEvidence += 1
                leftApartEvidence = 0
                if leftPinchEvidence >= evidenceCounterStateTrigger {
                    leftPinchState = .pinched
                } else {
                    leftPinchState = .possiblePinch
                }
            } else {
                leftApartEvidence += 1
                leftPinchEvidence = 0
                if leftApartEvidence >= evidenceCounterStateTrigger {
                    leftPinchState = .apart
                } else {
                    leftPinchState = .possibleApart
                }
            }
            isLeftPinching = (leftPinchState == .pinched)
        } else {
            if distance > pinchMaxDistance {
                rightPinchEvidence += 1
                rightApartEvidence = 0
                if rightPinchEvidence >= evidenceCounterStateTrigger {
                    rightPinchState = .pinched
                } else {
                    rightPinchState = .possiblePinch
                }
            } else {
                rightApartEvidence += 1
                rightPinchEvidence = 0
                if rightApartEvidence >= evidenceCounterStateTrigger {
                    rightPinchState = .apart
                } else {
                    rightPinchState = .possibleApart
                }
            }
            isRightPinching = (rightPinchState == .pinched)
        }
    }
    
    private func computePinchDistance(_ points: [CGPoint]) -> CGFloat {
        guard points.count > 8 else { return 0 }
        let thumbTip = points[4]
        let indexTip = points[8]
        let dx = thumbTip.x - indexTip.x
        let dy = thumbTip.y - indexTip.y
        return sqrt(dx*dx + dy*dy)
    }
    
    private func averageX(_ points: [CGPoint]) -> CGFloat {
        guard !points.isEmpty else { return 0 }
        let sum = points.reduce(0) { $0 + $1.x }
        return sum / CGFloat(points.count)
    }
    
    func normalizedPinchValue(for distance: CGFloat) -> CGFloat {
        let clamped = max(minDistance, min(distance, maxDistance))
        return (clamped - minDistance) / (maxDistance - minDistance)
    }
    
    func scaledValue(
        from distance: CGFloat,
        minOutput: Float,
        maxOutput: Float,
        sensitivity: Float = 1.0
    ) -> Float {
        let normalizedValue = normalizedPinchValue(for: distance)
        let adjustedValue = pow(Float(normalizedValue), sensitivity)
        let finalValue = minOutput + (maxOutput - minOutput) * adjustedValue
        return finalValue
    }
}




