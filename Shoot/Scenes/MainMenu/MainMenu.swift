//
//  MainMenu.swift
//  Shoot
//
//  Created by Ben Sutherland on 8/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenu: SKScene {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let UITouches = touches as? Set<UITouch> {
            for touch in UITouches {
                let location = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(location)
                
                if touchedNode == childNodeWithName("button") {
                    let scene = Game(fileNamed: "Game")
                    self.view?.presentScene(scene)
                }
            }
        }
    }
}
