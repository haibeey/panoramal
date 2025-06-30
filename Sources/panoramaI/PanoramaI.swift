//
//  Panoramal.swift
//
//
//  Created by Akerele Abraham on 27/01/2025.
//


import SwiftUI
import MetalKit
import UIKit

public struct PanoramaI: View {
    
    
    public enum Source {
        case urlPath(String)
        case url(URL)
        case namedFile(name: String, ext: String)
        case folderFile(name: String, folderPath: String)
    }
    
    @ObservedObject private var config: Config
    private let source: Source
    
    
    public init(
        source: Source,
        config: Config? = nil
    ) {
        let defaultConfig = Config(
            containerHeight: Float(UIScreen.main.bounds.height),
            containerWidth:  Float(UIScreen.main.bounds.width)
        )
        self._config = ObservedObject(wrappedValue: config ?? defaultConfig)
        self.source = source
    }
    
    
    @GestureState private var dragState: DragGesture.Value? = nil
    @GestureState private var magState: CGFloat = 1.0
    
    
    public var body: some View {
        Group {
            if config.isPlaceHolderTexture {
                Text("Invalid panorama file.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            } else {
                panoramaView()
                    .gesture(dragGesture)
                    .gesture(magnificationGesture)
            }
        }
    }
    
    @ViewBuilder
    private func panoramaView() -> some View {
        switch source {
        case .urlPath(let path):
            PanoramaView(urlPath: path, config: config)
        case .url(let url):
            PanoramaView(url: url, config: config)
        case .namedFile(let name, let ext):
            PanoramaView(name: name, ext: ext, config: config)
        case .folderFile(let name, let folder):
            PanoramaView(file_name: name, folder_path: folder, config: config)
        }
    }
    
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragState) { value, state, _ in
                state = value
                applyDrag(value)
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($magState) { value, state, _ in
                state = value
                applyMagnification(factor: value)
            }
    }
    
    
    private func applyDrag(_ value: DragGesture.Value) {
        let wF = config.containerWidth
        let hF = config.containerHeight
        let w = CGFloat(wF)
        let h = CGFloat(hF)
        
        let basePsiDelta   = angleDelta(from: value.translation.width,  dimension: w)
        let baseThetaDelta = angleDelta(
            from: value.translation.height,
            dimension: h,
            vFOV: verticalFOV(containerWidth: wF, containerHeight: hF)
        )
        
        let psiDelta   = basePsiDelta   * config.dragSensitivity
        let thetaDelta = baseThetaDelta * config.dragSensitivity
        
        config.updateAngles(
            psi:     config.psi   - psiDelta,
            theta:   config.theta + thetaDelta,
            rotation: 0
        )
    }
    
    private func applyMagnification(factor: CGFloat) {
        let newHFOV = Float(factor) * config.horizontalFieldView
        let clamped = min(max(newHFOV, 0.5), 3.0)
        config.updateHorizontalFieldView(hfov: clamped)
    }
    

    private func angleDelta(from delta: CGFloat, dimension: CGFloat, vFOV: Float = 90) -> Float {
        return Float(delta / dimension) * vFOV
    }
    
    private func verticalFOV(containerWidth w: Float, containerHeight h: Float) -> Float {
        let hfovRad = 60 * Float.pi / 180
        let vfovRad = 2 * atan(tan(hfovRad / 2) * (h / w))
        return vfovRad * 180 / Float.pi
    }
}

