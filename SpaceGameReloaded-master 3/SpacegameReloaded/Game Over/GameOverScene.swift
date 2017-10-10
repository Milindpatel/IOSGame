//
//  GameOverScene.swift
//  SpacegameReloaded
//
//  Created by Milind Patel on 2017-10-09.
//  Copyright © 2017 Training. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    var score:Int = 0
    
    var newGame:SKLabelNode!
    var scoreLabel:SKLabelNode!
     var playerScore:SKLabelNode!
//    var newGameButtonNode : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        playerScore = self.childNode(withName: "playerScore") as! SKLabelNode
        if UserDefaults.standard.bool(forKey: "Player2"){
            playerScore.text = "Player 2 Score"
        }else{
            playerScore.text = "Player 1 Score"
        }
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "\(score)"
        
        newGame = self.childNode(withName: "newGame") as! SKLabelNode
        
//        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
//        newGameButtonNode.texture = SKTexture(imageNamed: "player")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let node = self.nodes(at: location)
            
            if node[0].name == "newGame"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition : transition)
            }
            
//            if node[0].name == "newGameButton"{
//                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
//                let gameScene = GameScene(size: self.size)
//                self.view?.presentScene(gameScene, transition : transition)
//            }
        }
    }
}
