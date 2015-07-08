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
    
    override func didMoveToView(view: SKView) {
        initScene()
    }
    
    func initScene() {
        let playButton = self.childNodeWithName("playButton") as! SKSpriteNode
        playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        playButton.size = CGSizeMake(self.frame.width / 4, self.frame.width / 4)
        
        let shootLabel = self.childNodeWithName("shootLabel") as! SKLabelNode
        shootLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) / 3 * 2)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if let UITouches = touches as? Set<UITouch> {
            for touch in UITouches {
                let location = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(location)
                
                if touchedNode == childNodeWithName("playButton") {
                    let scene = Level1(fileNamed: "Level1")
                    self.view?.presentScene(scene)
                }
            }
        }
    }
}
