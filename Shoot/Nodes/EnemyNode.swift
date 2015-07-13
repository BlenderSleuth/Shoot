//
//  EnemyNode.swift
//  Shoot
//
//  Created by Benjamin Sutherland on 13/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

class EnemyNode: SKSpriteNode {
    var health = 4
    
    init(texture: SKTexture!, color: UIColor!, size: CGSize, position: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        
        self.position = position
        self.zPosition = 5
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 4, center: CGPointMake(0, -30))
        
        self.physicsBody?.categoryBitMask = enemyCategory
        self.physicsBody?.collisionBitMask = enemyCategory
        self.physicsBody?.contactTestBitMask = bulletCategory | boundaryCategory
        
        let exhaustFire = SKEmitterNode(fileNamed: "AlienExhaustFlames")
        exhaustFire.position = CGPointMake(0, self.frame.height / 2)
        self.addChild(exhaustFire)
    }
    
    convenience init(size: CGSize, position: CGPoint) {
        let texture = SKTexture(imageNamed: "alien_spaceship")
        let color = UIColor.whiteColor()
        self.init(texture: texture, color: color, size: size, position: position)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
