//
//  Brick.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/16/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class Brick: SKSpriteNode {
    
     enum BrickType {
        case Blue
        case Green
        case Grey
    }
    
    var type: BrickType
    var indestructible: Bool
    
    init(type: BrickType) {
        self.type = type
        self.indestructible = (type == .Grey)
        
        let texture: SKTexture
        
        switch type {
        case .Green:
            texture = SKTexture(imageNamed: "BrickGreen")
        case .Blue:
            texture = SKTexture(imageNamed: "BrickBlue")
        case .Grey:
            texture = SKTexture(imageNamed: "BrickGrey")
        }
        
        super.init(texture: texture, color: nil, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Brick
    }
    
    func hit() {
        switch type {
        case .Green:
            self.runAction(SKAction.removeFromParent())
            createExplosion()
        case .Blue:
            self.texture = SKTexture(imageNamed: "BrickGreen")
            self.type = .Green
        case .Grey:
            // indestructible bricks
            break
        }
    }
    
    func createExplosion() {
        let path = NSBundle.mainBundle().pathForResource("BrickExplosion", ofType: "sks")
        if let path = path {
            if let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                explosion.position = self.position
                self.parent?.addChild(explosion)
                
                let removeExplosion = SKAction.sequence([
                    SKAction.waitForDuration(NSTimeInterval(explosion.particleLifetime + explosion.particleLifetimeRange)),
                    SKAction.removeFromParent()
                ])
                
                explosion.runAction(removeExplosion)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
