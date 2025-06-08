//
//  Config.swift
//  
//
//  Created by Akerele Abraham on 27/01/2025.
//

import Foundation
import simd


public class Config : ObservableObject{
    @Published var panOffset: SIMD2<Float>
    @Published var psi: Float = 0
    @Published var theta: Float = 0
    @Published var rotation: Float = 0
    @Published var containerHeight : Float
    @Published var containerWidth : Float
    @Published var horizontalFieldView : Float = 65.0;
    
    let minTheta : Float = -90.0
    let maxTheta : Float = 90.0
    
    
    
    public init(containerHeight :Float,containerWidth : Float) {
        self.containerWidth = containerWidth
        self.containerHeight = containerHeight
        self.panOffset = SIMD2<Float>(1,1)
    }
    
    func updatePanOffset(x: Float,y: Float){
        DispatchQueue.main.async {
            self.panOffset = SIMD2<Float>(x,y)
        }
    }
    
    func updateAngles(psi: Float,theta: Float,rotation: Float){
        DispatchQueue.main.async {
            self.psi = psi
            self.theta = max(self.minTheta, min(self.maxTheta, theta))
            self.rotation = rotation
        }
    }
    
    public func  updateHorizontalFieldView(hfov : Float){
        DispatchQueue.main.async {
            if(hfov < 30){
                self.horizontalFieldView = 30
            }else if(hfov > 90){
                self.horizontalFieldView = 90
            }else{
                self.horizontalFieldView = hfov
            }
            
        }
    }
}
