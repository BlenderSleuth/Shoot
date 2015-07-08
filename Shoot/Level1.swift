//
//  Level1.swift
//  Shoot
//
//  Created by Ben Sutherland on 8/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import UIKit
import SpriteKit

class Level1: Level, SKPhysicsContactDelegate {
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        initLevel1()
    }
    
    func initLevel1() {
        let wall = childNodeWithName("wall") as! SKSpriteNode
        wall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) / 5 * 6)
        wall.size = CGSizeMake(self.frame.size.width / 5, self.frame.size.width / 20)
        wall.physicsBody = SKPhysicsBody(rectangleOfSize: wall.size)
    }
   
    func didBeginContact(contact: SKPhysicsContact) {
    }
}