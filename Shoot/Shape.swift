//
//  Shape.swift
//  Shoot
//
//  Created by Benjamin Sutherland on 25/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//
import CoreGraphics
class Shape {
    let numSides: Int
    let size: CGFloat
    
    init(numberOfSides: Int, size: CGFloat) {
        numSides = numberOfSides
        self.size = size
    }
}

class Square: Shape {
    convenience init(size: CGFloat) {
        self.init(numberOfSides: 4, size: size)
    }
}