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
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        /*
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"alien_spaceship.png"];
        
        CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
        CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 26 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, NULL, 35 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, NULL, 38 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, NULL, 45 - offsetX, 21 - offsetY);
        CGPathAddLineToPoint(path, NULL, 46 - offsetX, 27 - offsetY);
        CGPathAddLineToPoint(path, NULL, 38 - offsetX, 26 - offsetY);
        CGPathAddLineToPoint(path, NULL, 34 - offsetX, 33 - offsetY);
        CGPathAddLineToPoint(path, NULL, 36 - offsetX, 38 - offsetY);
        CGPathAddLineToPoint(path, NULL, 33 - offsetX, 41 - offsetY);
        CGPathAddLineToPoint(path, NULL, 36 - offsetX, 45 - offsetY);
        CGPathAddLineToPoint(path, NULL, 17 - offsetX, 48 - offsetY);
        CGPathAddLineToPoint(path, NULL, 13 - offsetX, 39 - offsetY);
        CGPathAddLineToPoint(path, NULL, 12 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, NULL, 3 - offsetX, 27 - offsetY);
        CGPathAddLineToPoint(path, NULL, 3 - offsetX, 22 - offsetY);
        CGPathAddLineToPoint(path, NULL, 10 - offsetX, 16 - offsetY);
        CGPathAddLineToPoint(path, NULL, 11 - offsetX, 11 - offsetY);
        CGPathAddLineToPoint(path, NULL, 14 - offsetX, 5 - offsetY);
        CGPathAddLineToPoint(path, NULL, 23 - offsetX, 1 - offsetY);
        
        CGPathCloseSubpath(path);
        
        sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
        */
        let offsetX = self.frame.size.width * self.anchorPoint.x
        
        
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
