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
    //let exhaustFire = SKEmitterNode(fileNamed: "AlienExhaustFlames")
    init(texture: SKTexture!, color: UIColor!, size: CGSize, position: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        
        self.position = position
        zPosition = 5
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 5 * 2)
        
        physicsBody?.categoryBitMask = enemyCategory
        physicsBody?.collisionBitMask = enemyCategory
        physicsBody?.contactTestBitMask = bulletCategory | boundaryCategory
        
        //exhaustFire.position = CGPointMake(0, frame.height / 2)
        //addChild(exhaustFire)
    }
    
    convenience init(size: CGSize, position: CGPoint) {
        let texture = SKTexture(imageNamed: "circle")
        let color = UIColor.whiteColor()
        self.init(texture: texture, color: color, size: size, position: position)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
