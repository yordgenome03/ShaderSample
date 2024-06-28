//
//  MetalView.swift
//  ShaderSample
//
//  Created by yotahara on 2024/06/27.
//

import SwiftUI
import MetalKit

struct Vertex {
    var position: SIMD2<Float>
    var color: SIMD4<Float>
}

struct TriangleRGBMetalView: UIViewRepresentable {
    @Binding var topRed: Float
    @Binding var topGreen: Float
    @Binding var topBlue: Float
    @Binding var leftRed: Float
    @Binding var leftGreen: Float
    @Binding var leftBlue: Float
    @Binding var rightRed: Float
    @Binding var rightGreen: Float
    @Binding var rightBlue: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self,
                    topRed: $topRed,
                    topGreen: $topGreen,
                    topBlue: $topBlue,
                    leftRed: $leftRed,
                    leftGreen: $leftGreen,
                    leftBlue: $leftBlue,
                    rightRed: $rightRed,
                    rightGreen: $rightGreen,
                    rightBlue: $rightBlue)
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = MTLCreateSystemDefaultDevice()
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.setNeedsDisplay()
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var parent: TriangleRGBMetalView
        var pipelineState: MTLRenderPipelineState?
        var vertexBuffer: MTLBuffer?
        var time: Float = 0.0
        
        @Binding var topRed: Float
        @Binding var topGreen: Float
        @Binding var topBlue: Float
        @Binding var leftRed: Float
        @Binding var leftGreen: Float
        @Binding var leftBlue: Float
        @Binding var rightRed: Float
        @Binding var rightGreen: Float
        @Binding var rightBlue: Float

        init(_ parent: TriangleRGBMetalView,
             topRed: Binding<Float>,
             topGreen: Binding<Float>, 
             topBlue: Binding<Float>,
             leftRed: Binding<Float>,
             leftGreen: Binding<Float>,
             leftBlue: Binding<Float>,
             rightRed: Binding<Float>,
             rightGreen: Binding<Float>,
             rightBlue: Binding<Float>) {
            self.parent = parent
            self._topRed = topRed
            self._topGreen = topGreen
            self._topBlue = topBlue
            self._leftRed = leftRed
            self._leftGreen = leftGreen
            self._leftBlue = leftBlue
            self._rightRed = rightRed
            self._rightGreen = rightGreen
            self._rightBlue = rightBlue
            super.init()

            setupPipeline()
            setupVertices()
        }

        func setupPipeline() {
            guard let device = MTLCreateSystemDefaultDevice(),
                  let library = device.makeDefaultLibrary(),
                  let vertexFunction = library.makeFunction(name: "vertex_main"),
                  let fragmentFunction = library.makeFunction(name: "fragment_main") else { return }

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create pipeline state: \(error)")
            }
        }

        func setupVertices() {
            let vertices: [Vertex] = [
                Vertex(position: SIMD2<Float>( 0.0,  0.5), color: SIMD4<Float>(topRed, topGreen, topRed, 1.0)),
                Vertex(position: SIMD2<Float>(-0.5, -0.5), color: SIMD4<Float>(leftRed, leftGreen, leftBlue, 1.0)),
                Vertex(position: SIMD2<Float>( 0.5, -0.5), color: SIMD4<Float>(rightRed, rightGreen, rightBlue, 1.0))
            ]

            let device = MTLCreateSystemDefaultDevice()
            vertexBuffer = device?.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.size * vertices.count, options: [])
        }

        func updateVertices() {
            guard let bufferPointer = vertexBuffer?.contents() else { return }
            let vertices = bufferPointer.assumingMemoryBound(to: Vertex.self)

            let amplitude: Float = 0.25
            let frequency: Float = 2.0

            vertices[0].position.y = 0.5 + amplitude * sin(time * frequency)
            vertices[1].position.y = -0.5 + amplitude * sin(time * frequency + 2.0 * Float.pi / 3.0)
            vertices[2].position.y = -0.5 + amplitude * sin(time * frequency + 4.0 * Float.pi / 3.0)
            
            vertices[0].color = SIMD4<Float>(topRed, topGreen, topBlue, 1.0)
            vertices[1].color = SIMD4<Float>(leftRed, leftGreen, leftBlue, 1.0)
            vertices[2].color = SIMD4<Float>(rightRed, rightGreen, rightBlue, 1.0)
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            time += 1.0 / Float(view.preferredFramesPerSecond)
            updateVertices()

            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let pipelineState = pipelineState,
                  let vertexBuffer = vertexBuffer else { return }

            let commandQueue = view.device?.makeCommandQueue()
            let commandBuffer = commandQueue?.makeCommandBuffer()

            let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
            renderEncoder?.setRenderPipelineState(pipelineState)
            renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            renderEncoder?.endEncoding()

            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}

#Preview {
    struct Preview: View {
        @State private var topRed: Float = 1.0
        @State private var topGreen: Float = 0.0
        @State private var topBlue: Float = 0.0
        @State private var leftRed: Float = 0.0
        @State private var leftGreen: Float = 1.0
        @State private var leftBlue: Float = 0.0
        @State private var rightRed: Float = 0.0
        @State private var rightGreen: Float = 0.0
        @State private var rightBlue: Float = 1.0
        
        var body: some View {
            TriangleRGBMetalView(topRed: $topRed,
                                 topGreen: $topGreen,
                                 topBlue: $topBlue,
                                 leftRed: $leftRed,
                                 leftGreen: $leftGreen,
                                 leftBlue: $leftBlue,
                                 rightRed: $rightRed,
                                 rightGreen: $rightGreen,
                                 rightBlue: $rightBlue)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    return Preview()
}
