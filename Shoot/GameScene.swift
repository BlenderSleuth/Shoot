//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //basescene? or levels
    
    let gun = SKSpriteNode(imageNamed: "spaceship.png")
    
    override func didMoveToView(view: SKView) {
        initGun()
        //background colour??
        self.scene?.physicsWorld.gravity = CGVectorMake(0, 0)
    }
    
    func initGun() {
        gun.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + self.frame.size.height / 4)
        gun.size = CGSizeMake(CGRectGetWidth(self.frame) / 5, CGRectGetWidth(self.frame) / 5)
        gun.zPosition = 10
        gun.name = "gun"
        self.addChild(gun)
    }
    
    func initBullet()  -> SKSpriteNode {
        let bulletTexture = SKTexture(imageNamed: "bullet.png")
        
        let bullet = SKSpriteNode(texture: bulletTexture)
        bullet.size = CGSizeMake(gun.size.width / 4, gun.size.height / 4)
        //make higher
        bullet.position = gun.position
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(50, 50))
        bullet.zPosition = 5
        return bullet
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            //make so only one is on screen at a time
            let bullet = initBullet()
            self.addChild(bullet)
            bullet.physicsBody?.applyImpulse(CGVectorMake(0, 200))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
