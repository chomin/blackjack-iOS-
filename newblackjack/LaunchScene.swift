//
//  LaunchScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/09.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class LaunchScene: SKScene {
	
	let bjButton=UIButton()
	let sjButton=UIButton()
	let comButton=UIButton()
	let pvpButton=UIButton()
	let netButton=UIButton()
	let scomButton=UIButton()
	let cancelButton=UIButton()
	
	
	let logo=SKSpriteNode(imageNamed:"Blackjack")
	
	
	override func didMove(to view: SKView) {
		
		//ロゴの設定及び設置
		let logowidth=self.view!.frame.width/6*5
		let logoheight=logowidth/5*2
		logo.size=CGSize(width:logowidth,height:logoheight)
		logo.position=CGPoint(x:self.view!.frame.width/2, y:self.view!.frame.height/4*3)
		self.addChild(logo)
		
		backgroundColor=SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		
		//ボタンの設定
		bjButton.frame = CGRect(x: 0,y: 0,width: 180,height: 40)	//大きさ
		bjButton.backgroundColor = UIColor.brown;	//背景色
		bjButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		bjButton.setTitle("blackjackで遊ぶ", for: UIControlState())
		bjButton.setTitleColor(UIColor.white, for: UIControlState())
		bjButton.setTitle("blackjackで遊ぶ", for: UIControlState.highlighted)
		bjButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		bjButton.layer.cornerRadius = 20.0   //角丸を適用
		bjButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2+40)
		bjButton.addTarget(self, action: #selector(LaunchScene.onClickbjButton(_:)), for: .touchUpInside)
		bjButton.addTarget(self, action: #selector(LaunchScene.touchDownbjButton(_:)), for: .touchDown)
		bjButton.addTarget(self, action: #selector(LaunchScene.enableButtons2(_:)), for: .touchUpOutside)
		self.view!.addSubview(bjButton)

		sjButton.frame = CGRect(x: 0,y: 0,width: 180,height: 40)	//大きさ
		sjButton.backgroundColor = UIColor.darkGray;	//背景色
		sjButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		sjButton.setTitle("shadowjackで遊ぶ", for: UIControlState())
		sjButton.setTitleColor(UIColor.white, for: UIControlState())
		sjButton.setTitle("shadowjackで遊ぶ", for: UIControlState.highlighted)
		sjButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		sjButton.layer.cornerRadius = 20.0   //角丸を適用
		sjButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2+120)
		sjButton.addTarget(self, action: #selector(LaunchScene.onClicksjButton(_:)), for: .touchUpInside)
		sjButton.addTarget(self, action: #selector(LaunchScene.touchDownsjButton(_:)), for: .touchDown)
		sjButton.addTarget(self, action: #selector(LaunchScene.enableButtons2(_:)), for: .touchUpOutside)
		self.view!.addSubview(sjButton)

		
		comButton.frame = CGRect(x: 0,y: 0,width: 180,height: 40)	//大きさ
		comButton.backgroundColor = UIColor.brown;	//背景色
		comButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		comButton.setTitle("CPUと対戦", for: UIControlState())
		comButton.setTitleColor(UIColor.white, for: UIControlState())
		comButton.setTitle("CPUと対戦", for: UIControlState.highlighted)
		comButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		comButton.layer.cornerRadius = 20.0   //角丸を適用
		comButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2)
		comButton.addTarget(self, action: #selector(LaunchScene.onClickCOMButton(_:)), for: .touchUpInside)
		comButton.addTarget(self, action: #selector(LaunchScene.touchDownCOMButton(_:)), for: .touchDown)
		comButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(comButton)
		comButton.isHidden=true
		
		
		pvpButton.frame = CGRect(x: 0,y: 0,width: 180,height: 40)	//大きさ
		pvpButton.backgroundColor = UIColor.brown;	//背景色
		pvpButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		pvpButton.setTitle("2人で対戦", for: UIControlState())
		pvpButton.setTitleColor(UIColor.white, for: UIControlState())
		pvpButton.setTitle("2人で対戦", for: UIControlState.highlighted)
		pvpButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		pvpButton.layer.cornerRadius = 20.0   //角丸を適用
		pvpButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2+80)
		pvpButton.addTarget(self, action: #selector(LaunchScene.onClickPVPButton(_:)), for: .touchUpInside)
		pvpButton.addTarget(self, action: #selector(LaunchScene.touchDownPVPButton(_:)), for: .touchDown)
		pvpButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(pvpButton)
		pvpButton.isHidden=true
		
		netButton.frame = CGRect(x: 0,y: 0,width: 180,height: 40)	//大きさ
		netButton.backgroundColor = UIColor.brown;	//背景色
		netButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		netButton.setTitle("ネットで対戦", for: UIControlState())
		netButton.setTitleColor(UIColor.white, for: UIControlState())
		netButton.setTitle("ネットで対戦", for: UIControlState.highlighted)
		netButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		netButton.layer.cornerRadius = 20.0   //角丸を適用
		netButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2+160)
		netButton.addTarget(self, action: #selector(LaunchScene.onClickNetButton(_:)), for: .touchUpInside)
		netButton.addTarget(self, action: #selector(LaunchScene.touchDownNetButton(_:)), for: .touchDown)
		netButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(netButton)
		netButton.isHidden=true
		
		scomButton.frame = CGRect(x: 0,y: 0,width: 180,height: 40)	//大きさ
		scomButton.backgroundColor = UIColor.darkGray;	//背景色
		scomButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		scomButton.setTitle("CPUと対戦", for: UIControlState())
		scomButton.setTitleColor(UIColor.white, for: UIControlState())
		scomButton.setTitle("CPUと対戦", for: UIControlState.highlighted)
		scomButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		scomButton.layer.cornerRadius = 20.0   //角丸を適用
		scomButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2)
		scomButton.addTarget(self, action: #selector(LaunchScene.onClicksCOMButton(_:)), for: .touchUpInside)
		scomButton.addTarget(self, action: #selector(LaunchScene.touchDownsCOMButton(_:)), for: .touchDown)
		scomButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(scomButton)
		scomButton.isHidden=true
		
		cancelButton.frame = CGRect(x: 0,y: 0,width: 160,height: 30)
		cancelButton.backgroundColor = UIColor.gray
		cancelButton.layer.masksToBounds = true
		cancelButton.setTitle("キャンセル", for: UIControlState())
		cancelButton.setTitleColor(UIColor.white, for: UIControlState())
		cancelButton.setTitle("キャンセル", for: UIControlState.highlighted)
		cancelButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		cancelButton.layer.position = CGPoint(x: 100, y:self.view!.frame.height-20)
		cancelButton.addTarget(self, action: #selector(self.onClickCancelButton(_:)), for: .touchUpInside)
		cancelButton.addTarget(self, action: #selector(self.touchDownCancelButton(_:)), for: .touchDown)
		cancelButton.addTarget(self, action: #selector(self.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(cancelButton)
		cancelButton.isHidden=true

	}
	
	
	
	func onClickbjButton(_ sender : UIButton){
		bjButton.isHidden=true
		sjButton.isHidden=true
		cancelButton.isHidden=false
		comButton.isHidden=false
		pvpButton.isHidden=false
		netButton.isHidden=false
		
		sjButton.isEnabled=true	//cancel用に戻しておく
	}
	
	func onClicksjButton(_ sender : UIButton){
		bjButton.isHidden=true
		sjButton.isHidden=true
		cancelButton.isHidden=false
		scomButton.isHidden=false
		
		bjButton.isEnabled=true
	}
	
	func onClickCOMButton(_ sender : UIButton){
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		
		//ボタンを隠す
		comButton.isHidden=true
		pvpButton.isHidden=true
		netButton.isHidden=true
		cancelButton.isHidden=true
		
		Cards.mode = .com
		let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //GameSceneに移動

		
	}
	
	func onClickPVPButton(_ sender : UIButton){
		
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		
		//ボタンを隠す
		comButton.isHidden=true
		pvpButton.isHidden=true
		netButton.isHidden=true
		cancelButton.isHidden=true
		
		Cards.mode = .pvp
		let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //GameSceneに移動
		
	}
	
	func onClickNetButton(_ sender : UIButton){
		
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		
		//ボタンを隠す
		comButton.isHidden=true
		pvpButton.isHidden=true
		netButton.isHidden=true
		cancelButton.isHidden=true
		
		Cards.mode = .netp1  //setcardでの認識に必要
		let gameScene:waitingScene = waitingScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //waitingSceneに移動
		
	}
	
	func onClicksCOMButton(_ sender : UIButton){
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		
		//ボタンを隠す
		scomButton.isHidden=true
		cancelButton.isHidden=true
		
		Cards.mode = .scom
		let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //GameSceneに移動
		
		
	}
	
	func onClickCancelButton(_ sender : UIButton){
		bjButton.isHidden=false
		sjButton.isHidden=false
		pvpButton.isHidden=true
		comButton.isHidden=true
		netButton.isHidden=true
		scomButton.isHidden=true
		cancelButton.isHidden=true
		
		pvpButton.isEnabled=true
		comButton.isEnabled=true
		netButton.isEnabled=true
		scomButton.isEnabled=true
	}
	
	
	//同時押し対策
	func touchDownbjButton(_ sender: UIButton){
		sjButton.isEnabled=false
	}
	func touchDownsjButton(_ sender: UIButton){
		bjButton.isEnabled=false
	}
	func touchDownCOMButton(_ sender: UIButton){
		pvpButton.isEnabled=false
		netButton.isEnabled=false
	}
	func touchDownPVPButton(_ sender: UIButton){
		comButton.isEnabled=false
		netButton.isEnabled=false
	}
	func touchDownNetButton(_ sender: UIButton){
		comButton.isEnabled=false
		pvpButton.isEnabled=false
	}
	func touchDownsCOMButton(_ sender: UIButton){
		
	}
	func touchDownCancelButton(_ sender: UIButton){
		comButton.isEnabled=false
		pvpButton.isEnabled=false
		netButton.isEnabled=false
		scomButton.isEnabled=false
	}
	
	func enableButtons(_ sender:UIButton){
		pvpButton.isEnabled=true
		comButton.isEnabled=true
		netButton.isEnabled=true
		scomButton.isEnabled=true
		cancelButton.isEnabled=true
	}
	func enableButtons2(_ sender:UIButton){
		sjButton.isEnabled=true
		bjButton.isEnabled=true
	}
	


	
}
