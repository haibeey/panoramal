//
//  Panoramal.swift
//
//
//  Created by Akerele Abraham on 27/01/2025.
//

import SwiftUI
import MetalKit
import UIKit
import Foundation

public struct PanoramaI: View {
    
    private let panoView: PanoramaView
    @ObservedObject private var config: Config
    
    @State private var onPointerDownPsi: Float = 0
    @State private var onPointerDownTheta: Float = 0
    
    @State private var onPointerDownPointerX: Float = 0
    @State private var onPointerDownPointerY: Float = 0
    
    @State private var lastTouch: Bool = false
    
    public init(urlPath: String? = nil, name: String? = nil, ext: String? = nil, folder_path: String? = nil) {
        let configInstance = Config(containerHeight: Float(UIScreen.main.bounds.height),
                                    containerWidth: Float(UIScreen.main.bounds.width))
        self._config = ObservedObject(wrappedValue: configInstance)
        
        if let urlPath = urlPath {
            panoView = PanoramaView(urlPath: urlPath, config: configInstance)
        } else if let name = name, let ext = ext {
            panoView = PanoramaView(name: name, ext: ext, config: configInstance)
        }else if let name = name, let folder_path = folder_path{
            panoView = PanoramaView(file_name: name, folder_path: folder_path, config: configInstance)
        }else {
            fatalError("Must provide either panorama URL or name/ext of file in the app resource group")
        }
    }
    
    
    public var body: some View {
        panoView
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        
                        if(!lastTouch){
                            lastTouch = true
                            onPointerDownPointerX = Float(value.location.x)
                            onPointerDownPointerY = Float(value.location.y)
                            
                            onPointerDownPsi = self.config.psi
                            onPointerDownTheta = self.config.theta
                            return
                        }
                        
                        let x : Float = Float(value.location.x)
                        let y : Float = Float(value.location.y)
                        
                        let width = self.config.containerWidth
                        let height = self.config.containerHeight
                        
                        let  psi =
                        ((atan(onPointerDownPointerX / width * 2.0 - 1.0) - atan(x / width * 2.0 - 1.0)) * 180 / .pi * 100.0 / 90.0 ) + onPointerDownPsi
                        
                        
                        let vfov = 2 * atan(tan(75.0 / 360 * .pi) * height / width) * 180.0 / .pi
                        
                        let  theta =
                        ((atan(y / height * 2.0 - 1.0) - atan(onPointerDownPointerY / height * 2.0 - 1.0)) * 180.0 / .pi * vfov / 90) + onPointerDownTheta
                        
                        
                        // rotation is constant for now as we assume panning with your hands.
                        config.updateAngles(psi: psi, theta: theta, rotation: 0)
                        
                    }
                    .onEnded { value in
                        
                        onPointerDownPointerX = Float(value.location.x)
                        onPointerDownPointerY = Float(value.location.y)
                        
                        onPointerDownPsi = self.config.psi
                        onPointerDownTheta = self.config.theta
                        
                        lastTouch = false
                    }
            )
    }
}
