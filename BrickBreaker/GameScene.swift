//
//  GameScene.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/14/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var paddle: SKSpriteNode!
    var touchLocation: CGPoint!
    
    // MARK: -
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let xMovement = touch.locationInNode(self).x - touchLocation.x
            
            paddle.position = CGPointMake(paddle.position.x + xMovement, paddle.position.y)
            
            let paddleMinX = -paddle.size.width * 0.25
            let paddleMaxX = self.size.width + paddle.size.width * 0.25
            
            if paddle.position.x < paddleMinX {
                paddle.position = CGPointMake(paddleMinX, paddle.position.y)
            }
            
            if paddle.position.x > paddleMaxX {
                paddle.position = CGPointMake(paddleMaxX, paddle.position.y)
            }
            
            touchLocation = touch.locationInNode(self)
        }
    }
    
    // MARK: -
    
    func createBallWithLocation(position: CGPoint, velocity: CGVector) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.name = name
        ball.position = position
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.velocity = velocity
        
        addChild(ball)
        return ball
    }
    
    
    // MARK: - Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        createBallWithLocation(CGPointMake(self.size.width/2, self.size.height/2), velocity: CGVectorMake(40, 180))
        
        paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.position = CGPointMake(self.size.width/2, 90)
        addChild(paddle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}