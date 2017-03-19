//
//  GameViewController.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/01.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//
//
import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
	

	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let scene = LaunchScene(size: view.bounds.size)
		let skView = view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .resizeFill
		skView.presentScene(scene)  //LaunchSceneに移動
		
		
		
		
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
		
		
		
		

	}
	
	
	
	
	
}
