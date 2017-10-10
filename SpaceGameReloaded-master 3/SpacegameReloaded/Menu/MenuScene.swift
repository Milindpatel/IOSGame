//
//  MenuScene.swift
//  SpacegameReloaded
//
//  Created by Milind Patel on 2017-10-07.
//  Copyright © 2017 Training. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var starfield : SKEmitterNode!
    
    var newGameButtonNode : SKLabelNode!
    var playerButtonNode : SKLabelNode!
    var playerLabelNode : SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        starfield = self.childNode(withName: "starfield") as! SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGame") as! SKLabelNode
        playerButtonNode = self.childNode(withName: "playerButton") as! SKLabelNode

        playerLabelNode = self.childNode(withName: "playerLabel") as! SKLabelNode

        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: "Player2"){
            playerLabelNode.text = "Player 2"
        }else{
            playerLabelNode.text = "Player 1"
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGame"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if nodesArray.first?.name == "playerButton"{
                changePlayer()
            }
        }
    }
    
    
    func changePlayer(){
        let userDefaults = UserDefaults.standard
        
        if playerLabelNode.text == "Player 1"{
            playerLabelNode.text = "Player 2"
            userDefaults.set(true, forKey: "Player2")
            
        }else{
             playerLabelNode.text = "Player 1"
            userDefaults.set(false, forKey: "Player2")
        }
        
        userDefaults.synchronize()
    }
}


