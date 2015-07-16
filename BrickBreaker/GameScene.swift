//
//  GameScene.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/14/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let Ball: UInt32     = 0
        static let Paddle: UInt32   = 0b1
        static let Brick: UInt32    = 0b10
    }
    
    let ballSpeed: CGFloat = 200
    
    var paddle: SKSpriteNode!
    var touchLocation: CGPoint!
    
    var brickLayer: SKNode!
    var ballReleased: Bool!
    
    // MARK: -
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !ballReleased {
            paddle.removeAllChildren()
            
            createBallWithLocation(CGPointMake(paddle.position.x, paddle.position.y + paddle.size.height * 0.5), velocity: CGVectorMake(0, ballSpeed))
            ballReleased = true
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
    
    // MARK: - SKPhysicsContactDelegate Methods
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        } else {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        
        // contact between ball and paddle
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Paddle {
                if firstBody.node?.position.y > secondBody.node?.position.y {
                // get contact point in paddle coordinates
                let pointInPaddle = secondBody.node?.convertPoint(contact.contactPoint, fromNode: self)
                // get contact position as percentage of paddle's width
                let contactPosition = (secondBody.node!.frame.size.width * 0.5 + pointInPaddle!.x) / secondBody.node!.frame.size.width
                // cap percentage between 0 to 1 and flip it
                let multiplier = 1.0 - fmax(fmin(contactPosition, 1.0), 0.0)
                // calculate angle based on ball position in paddle
                let angle = (CGFloat(M_PI_2) * multiplier) + CGFloat(M_PI_4)
                // convert angle to vector
                let direction = CGVectorMake(cos(angle), sin(angle))
                
                firstBody.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
            }
        }
        
        // contact between ball and brick
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Brick {
            if let brick = (secondBody.node as? Brick) {
                brick.hit()
            }
        }
    }
    
    // MARK: -
    
    func createBallWithLocation(position: CGPoint, velocity: CGVector) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.name = "ball"
        ball.position = position
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.velocity = velocity
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Brick
        
        addChild(ball)
        return ball
    }
    
    func loadLevel(level: Int) {
        var collection: [[Brick.BrickType!]] = []
        
        switch level {
        case 0:
            collection = [
                [.Green, .Green, .Green, .Green, .Green, .Green],
                [.Green, .Green, .Green, .Green, .Green, .Green],
                [.Green, .Green, nil, nil, .Green, .Green],
                [nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil],
                [.Blue, .Blue, .Blue, .Blue, .Blue, .Blue],
            ]
        default:
            break
        }
        
        for (rowIndex, row) in enumerate(collection) {
            for (colIndex, brickType) in enumerate(row) {
                if brickType != nil {
                    let brick = Brick(type: brickType)
                    brick.position = CGPointMake(
                        2 + brick.size.width * 0.5 + (brick.size.width + 3) * CGFloat(colIndex),
                        -(2 + brick.size.height * 0.5 + (brick.size.height + 3) * CGFloat(rowIndex)))
                    brickLayer.addChild(brick)
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        // setup brick layer
        brickLayer = SKNode()
        brickLayer.position = CGPointMake(0, self.size.height)
        addChild(brickLayer)
        
        // load level
        loadLevel(0)
        
        paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.position = CGPointMake(self.size.width/2, 90)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.size)
        paddle.physicsBody?.dynamic = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        addChild(paddle)
        
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.position = CGPointMake(0, paddle.size.height)
        paddle.addChild(ball)
        
        ballReleased = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}