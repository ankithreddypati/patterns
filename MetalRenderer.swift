
//
//  MetalRenderer.swift.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/13/25.
//

import MetalKit
import simd


class MetalRenderer: NSObject, MTKViewDelegate {
    // Metal objects expensive 
    let device: MTLDevice!
    let commandQueue: MTLCommandQueue!
    
    // Triangle Pipeline
    var trianglePipelineState: MTLRenderPipelineState!
    
    // Fractal pipeline
    var treePipelineState: MTLRenderPipelineState!
    
    // Buffers for triangle, circle
    var vertexBuffer: MTLBuffer!
    
    //  Buffer for thick fractal quads
    var treeQuadBuffer: MTLBuffer!
    var quadVertexCount: Int = 0
    
    // Uniform buffer used for fractal and triangle
    var uniformBuffer: MTLBuffer!
    
    // Fractal params
    var recursionDepth: Int = 15
    var branchAngle: Float = .pi / 6
    
    // Voronoi
    var voronoiPipelineState: MTLRenderPipelineState!
    var voronoiCell: VoronoiCell?
    var lastFrameTime: CFTimeInterval = 0.0 
    
    // voronoi parameters
    var cellMovementSpeed: Float = 0.5
    var numberOfCells: Float = 32
    
    // Pipelines
    var fluidComputePipeline: MTLComputePipelineState!
    var fluidRenderPipeline: MTLRenderPipelineState!
    
    //  Buffers
    var fluidParticlesBuffer: MTLBuffer!
    var fluidUniformsBuffer: MTLBuffer!
    
    // Sliders params
    var gravityY: Float = -0.1
    var viscosity: Float = 0.5
    

    
    
    
    
    // Rotation / viewport / pattern
    var rotationAngle: Float = 0.0
    var viewportSize: CGSize = .zero
    var patternType: PatternType = .triangle
    
    override init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        super.init()
        createPipelineStates()
        createBuffers()
    }
    
    //  Pipeline States
    func createPipelineStates() {
        let library = device.makeDefaultLibrary()!
        
        // Triangle pipeline
        let triangleVertexFunction = library.makeFunction(name: "triangle_vertex_main")!
        let triangleFragmentFunction = library.makeFunction(name: "triangle_fragment_main")!
        let triangleDescriptor = MTLRenderPipelineDescriptor()
        triangleDescriptor.vertexFunction = triangleVertexFunction
        triangleDescriptor.fragmentFunction = triangleFragmentFunction
        triangleDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        triangleDescriptor.vertexDescriptor = Vertex.buildDefaultVertexDescriptor()
        
        do {
            trianglePipelineState = try device.makeRenderPipelineState(descriptor: triangleDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Tree pipeline
        let treeVertexFunction = library.makeFunction(name: "tree_vertex_main")!
        let treeFragmentFunction = library.makeFunction(name: "tree_fragment_main")!
        let treeDescriptor = MTLRenderPipelineDescriptor()
        treeDescriptor.vertexFunction = treeVertexFunction
        treeDescriptor.fragmentFunction = treeFragmentFunction
        treeDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        
        let thickDescriptor = MTLVertexDescriptor()
        thickDescriptor.attributes[0].format = .float2
        thickDescriptor.attributes[0].bufferIndex = 0
        thickDescriptor.attributes[0].offset = 0
        thickDescriptor.attributes[1].format = .float3
        thickDescriptor.attributes[1].bufferIndex = 0
        thickDescriptor.attributes[1].offset = MemoryLayout<ThickVertex>.offset(of: \.color)!
        thickDescriptor.layouts[0].stride = MemoryLayout<ThickVertex>.stride
        treeDescriptor.vertexDescriptor = thickDescriptor
        
        do {
            treePipelineState = try device.makeRenderPipelineState(descriptor: treeDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Voronoi pipeline
        let voronoiVertexFunction = library.makeFunction(name: "vertex_voronoi")!
        let voronoiFragmentFunction = library.makeFunction(name: "voronoiFragmentShader")!
        let voronoiDescriptor = MTLRenderPipelineDescriptor()
        voronoiDescriptor.vertexFunction = voronoiVertexFunction
        voronoiDescriptor.fragmentFunction = voronoiFragmentFunction
        voronoiDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            voronoiPipelineState = try device.makeRenderPipelineState(descriptor: voronoiDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Fluid pipeline
        let fluidComputeFunc = library.makeFunction(name: "updateFluid")!
        fluidComputePipeline = try! device.makeComputePipelineState(function: fluidComputeFunc)
        
        // Render pipeline for points
        let vertexFunc = library.makeFunction(name: "fluid_vertex")!
        let fragmentFunc = library.makeFunction(name: "fluid_fragment")!
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = vertexFunc
        renderDesc.fragmentFunction = fragmentFunc
        renderDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        fluidRenderPipeline = try! device.makeRenderPipelineState(descriptor: renderDesc)
        
        

        
        
        
    }
    
    // MARK: - Buffers
    func createBuffers() {
        // Triangle
        let triangleVertices: [Vertex] = [
            Vertex(position2d: SIMD2<Float>(0, 1), colorRgb: SIMD3<Float>(1, 0, 0)),
            Vertex(position2d: SIMD2<Float>(-1, -1), colorRgb: SIMD3<Float>(0, 1, 0)),
            Vertex(position2d: SIMD2<Float>(1, -1), colorRgb: SIMD3<Float>(0, 0, 1))
        ]
        
        vertexBuffer = device.makeBuffer(
            bytes: triangleVertices,
            length: MemoryLayout<Vertex>.stride * triangleVertices.count,
            options: []
        )
        
        // Uniform buffer for fractal
        uniformBuffer = device.makeBuffer(
            length: MemoryLayout<FractalUniforms>.stride,
            options: []
        )
        
   
        updateFractalTree()
        
        // Fluid
        // Particles
        fluidParticlesBuffer = device.makeBuffer(
            length: MemoryLayout<Particle>.stride * maxParticles,
            options: .storageModeShared
        )
        
        // Uniforms
        fluidUniformsBuffer = device.makeBuffer(
            length: MemoryLayout<FluidUniforms>.stride,
            options: .storageModeShared
        )
        
        var defaultUniforms = FluidUniforms(
            dt: 0.008,
            gravityY: gravityY,
            viscosity: viscosity,
            p0: 2.0,
            K: 500.0,
            h: 0.07,
            resolution: SIMD2<Float>(800, 600)
        )
        
        memcpy(fluidUniformsBuffer.contents(), &defaultUniforms, MemoryLayout<FluidUniforms>.stride)
        
        var particles = [Particle]()
        particles.reserveCapacity(maxParticles)
        
        for _ in 0..<maxParticles {
            let px = Float.random(in: 0.3...0.7)
            let py = Float.random(in: 0.3...0.7)
            let vx = Float.random(in: -0.1...0.1)
            let vy = Float.random(in: -0.1...0.1)
            particles.append(
                Particle(
                    position: SIMD2<Float>(px, py),
                    velocity: SIMD2<Float>(vx, vy)
                )
            )
        }
        
        memcpy(fluidParticlesBuffer.contents(), particles, MemoryLayout<Particle>.stride * maxParticles)
        
       
    }
    
    func createThickFractal(
        position: SIMD2<Float>,
        length: Float,
        angle: Float,
        depth: Int,
        maxDepth: Int,
        thickness: Float,
        vertices: inout [ThickVertex]
    ) {
        if depth == 0 {
            return
        }
        
        let endPos = position + SIMD2<Float>(
            length * cos(angle),
            length * sin(angle)
        )
        
        addQuadForBranch(
            startPos: position,
            endPos: endPos,
            thickness: thickness,
            depth: depth,
            maxDepth: maxDepth,
            vertices: &vertices
        )
        
        if depth > 1 {
            let newThickness = thickness * 0.8
            let newLength = length * 0.67
            
            createThickFractal(
                position: endPos,
                length: newLength,
                angle: angle + branchAngle,
                depth: depth - 1,
                maxDepth: maxDepth,
                thickness: newThickness,
                vertices: &vertices
            )
            
            createThickFractal(
                position: endPos,
                length: newLength,
                angle: angle - branchAngle,
                depth: depth - 1,
                maxDepth: maxDepth,
                thickness: newThickness,
                vertices: &vertices
            )
        }
    }
    
    func addQuadForBranch(
        startPos: SIMD2<Float>,
        endPos: SIMD2<Float>,
        thickness: Float,
        depth: Int,
        maxDepth: Int,
        vertices: inout [ThickVertex]
    ) {
        let dir = normalize(endPos - startPos)
        let perp = SIMD2<Float>(-dir.y, dir.x)
        let half = (thickness / 2)
        let offset = perp * half
        
        let depthRatio = 1.0 - (Float(depth) / Float(maxDepth))
        let brown = SIMD3<Float>(0.5, 0.25, 0.1) // Trunk color
        let green = SIMD3<Float>(0.2, 0.6, 0.2) // Leaves color
        let color = brown * (1.0 - depthRatio) + green * depthRatio
        
        let v1 = ThickVertex(position: startPos + offset, color: color)
        let v2 = ThickVertex(position: startPos - offset, color: color)
        let v3 = ThickVertex(position: endPos + offset, color: color)
        let v4 = ThickVertex(position: endPos - offset, color: color)
        
        vertices.append(v1)
        vertices.append(v2)
        vertices.append(v3)
        vertices.append(v3)
        vertices.append(v2)
        vertices.append(v4)
    }
    
    func updateFractalTree() {
        var thickVertices: [ThickVertex] = []
        createThickFractal(
            position: SIMD2<Float>(0, 0),
            length: 0.7,
            angle: .pi / 2, // grows up
            depth: recursionDepth,
            maxDepth: recursionDepth,
            thickness: 0.08,
            vertices: &thickVertices
        )
        
        quadVertexCount = thickVertices.count
        let neededSize = MemoryLayout<ThickVertex>.stride * quadVertexCount
        
        if treeQuadBuffer == nil || treeQuadBuffer.length < neededSize {
            treeQuadBuffer = device.makeBuffer(length: neededSize, options: [])
        } else {
            memset(treeQuadBuffer.contents(), 0, treeQuadBuffer.length)
        }
        
        memcpy(treeQuadBuffer.contents(), thickVertices, neededSize)
    }
    
    // Parameters updation
    func updateFractalParameters(depth: Float, angle: Float) {
        recursionDepth = Int(depth)
        branchAngle = angle
        updateFractalTree()
    }
    
    // For the Voronoi sliders
    func updateVoronoiParameters(speed: Float, count: Float) {
        self.cellMovementSpeed = speed
        self.numberOfCells = count
    }
    
    
    // Fluid params updation
    func updateFluidParams(gravity: Float, viscosity: Float) {
        self.gravityY = gravity
        self.viscosity = viscosity
    }
    
   
    func updateRotation(angle: Float) {
        rotationAngle = angle
    }
    
    // MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = size
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        switch patternType {
            case .triangle:
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
                renderEncoder.setRenderPipelineState(trianglePipelineState)
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                
                let uniforms = FractalUniforms(
                    transform: float4x4(rotationZ: rotationAngle),
                    recursionDepth: 0,
                    branchAngle: 0
                )
                
                let ptr = uniformBuffer.contents().bindMemory(to: FractalUniforms.self, capacity: 1)
                ptr.pointee = uniforms
                renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
                renderEncoder.endEncoding()
                
            case .treeFractal:
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
                renderEncoder.setRenderPipelineState(treePipelineState)
                
                let scale = float4x4(scale: SIMD2<Float>(0.9, 0.9))
                let translate = float4x4(translation: SIMD2<Float>(0, -1))
                let transform = translate * scale
                
                let uniforms = FractalUniforms(
                    transform: transform,
                    recursionDepth: Float(recursionDepth),
                    branchAngle: branchAngle
                )
                
                let ptr = uniformBuffer.contents().bindMemory(to: FractalUniforms.self, capacity: 1)
                ptr.pointee = uniforms
                renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                
                renderEncoder.setVertexBuffer(treeQuadBuffer, offset: 0, index: 0)
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: quadVertexCount)
                renderEncoder.endEncoding()
                
            case .voronoi:
                if voronoiCell == nil {
                    voronoiCell = VoronoiCell()
                }
                
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
                renderEncoder.setRenderPipelineState(voronoiPipelineState)
                
                let now = CACurrentMediaTime()
                let deltaTime = (lastFrameTime == 0) ? 0 : Float(now - lastFrameTime)
                lastFrameTime = now
                
                voronoiCell!.uniforms.time = Float(now)
                voronoiCell!.uniforms.resolution = SIMD2<Float>(
                    Float(view.drawableSize.width),
                    Float(view.drawableSize.height)
                )
                voronoiCell!.uniforms.cellMovementSpeed = cellMovementSpeed
                voronoiCell!.uniforms.numPoints = Int32(numberOfCells)
                
                voronoiCell!.updatePoints(deltaTime: deltaTime)
                
                var uniformsCopy = voronoiCell!.uniforms
                renderEncoder.setFragmentBytes(&uniformsCopy, length: MemoryLayout<VoronoiUniforms>.stride, index: 0)
                
                renderEncoder.setFragmentBytes(voronoiCell!.points, length: MemoryLayout<VoronoiPoint>.stride * kMaxPoints, index: 1)
                
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
                renderEncoder.endEncoding()
                
            case .Fluid:
                if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
                    computeEncoder.setComputePipelineState(fluidComputePipeline)
                    
                    var uni = fluidUniformsBuffer.contents().bindMemory(to: FluidUniforms.self, capacity: 1).pointee
                    uni.gravityY = gravityY
                    uni.viscosity = viscosity
                    memcpy(fluidUniformsBuffer.contents(), &uni, MemoryLayout<FluidUniforms>.stride)
                    
                    computeEncoder.setBuffer(fluidParticlesBuffer, offset: 0, index: 0)
                    computeEncoder.setBuffer(fluidUniformsBuffer, offset: 0, index: 1)
                    
                    let threadsPerGroup = MTLSize(width: 32, height: 1, depth: 1)
                    let numThreadgroups = MTLSize(width: (maxParticles + 31) / 32, height: 1, depth: 1)
                    
                    computeEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
                    computeEncoder.endEncoding()
                }
                
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                    renderEncoder.setRenderPipelineState(fluidRenderPipeline)
                    renderEncoder.setVertexBuffer(fluidParticlesBuffer, offset: 0, index: 0)
                    
                    renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: maxParticles)
                    renderEncoder.endEncoding()
                }
            
            

            


            default:
                break
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}


extension float4x4 {
    init(_ s: Float) {
        self.init(
            [s, 0, 0, 0],
            [0, s, 0, 0],
            [0, 0, s, 0],
            [0, 0, 0, 1]
        )
    }
    
    init(rotationZ angle: Float) {
        self = float4x4(
            [cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }
}

extension float4x4 {
    init(scale s: SIMD2<Float>) {
        self.init(
            [s.x, 0, 0, 0],
            [0, s.y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }
    
    init(translation t: SIMD2<Float>) {
        self.init(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [t.x, t.y, 0, 1]
        )
    }
}
