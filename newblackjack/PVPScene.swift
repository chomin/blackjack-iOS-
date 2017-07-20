//
//  PVPScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/09.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class PVPScene: SKScene {   //2人対戦用
	//効果音を生成
	var playcard : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
	
	var card:[SKSpriteNode] = []	  //カードの画像(空の配列)
	let ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	let cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var hcounter=0	//p1がヒットした数
	//ボタンを生成
	let hitButton = UIButton()
	let standButton = UIButton()
	let resetButton=UIButton()
	let titleButton=UIButton()
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンを表示→結果を表示
	
	var scounter=0	//スタンドが押された数(0でp1のターン、1でp2のターン)
	var chcounter=0 //comがヒットした数
	
	let p1Label=SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,p2と表示
	let p2Label=SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	
	
	
	
	override func didMove(to view: SKView) {
		//効果音の設定
		// サウンドファイルのパスを生成
		let playcardPath = Bundle.main.path(forResource: "カード音", ofType: "mp3")!    //m4aは不可
		let playcardsound:URL = URL(fileURLWithPath: playcardPath)
		// AVAudioPlayerのインスタンスを作成
		do {
			playcard = try AVAudioPlayer(contentsOf: playcardsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		// バッファに保持していつでも再生できるようにする
		playcard.prepareToPlay()

		
		
		let cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		//ラベルの設定をしておく
		
		p1Label.fontSize = cheight*20/138	//20はもともとの定数、138は7plusでのcheightの値
		p1Label.horizontalAlignmentMode = .left	//左寄せ
		p1Label.position = CGPoint(x:0, y:cheight+cheight*35/138)
		p1Label.text="P1"
		p1Label.fontColor=SKColor.blue
		addChild(p1Label)
		
		p2Label.fontSize = cheight*20/138
		p2Label.horizontalAlignmentMode = .left	//左寄せ
		p2Label.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*55/138)
		p2Label.text="P2"
		p2Label.fontColor=SKColor.red
		addChild(p2Label)
		
		ppLabel.fontSize = cheight*30/138
		ppLabel.horizontalAlignmentMode = .left	//左寄せ
		ppLabel.position = CGPoint(x:0, y:cheight+cheight*5/138)
		addChild(ppLabel)
		
		cpLabel.fontSize = cheight*30/138
		cpLabel.horizontalAlignmentMode = .left
		cpLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*30/138)
		addChild(cpLabel)
		
		
		backgroundColor = SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		
		//card[0]に裏面を格納
		card.append(SKSpriteNode(imageNamed:"z02"))
		
		//クローバー、ダイヤ、ハート、スペードの順に画像を格納
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "c\(i)-1"))	  //配列に画像を追加
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "d\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "h\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "s\(i)-1"))
		}
		
		//cardのサイズを設定
		for i in card{
			i.size=CGSize(width:cwidth,height:cheight)
		}
		
		//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
		let pccards=Cards().setcard()
		
		//各手札を表示
		for (index,value) in pccards.pcards.enumerated(){
			card[value].position=CGPoint(x:cwidth/2+cwidth*CGFloat(index),y:cheight/2)
			self.addChild(card[value])
		}
		
		//cpuの1枚目は表,2枚目は裏向き
		card[pccards.ccards[0]].position=CGPoint(x:cwidth/2,y:frame.size.height-cheight/2)
		card[0].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
		self.addChild(card[pccards.ccards[0]])
		self.addChild(card[0])
		
		//得点表示
		ppLabel.text=pccards.pp
		
		
		
		
		
		// ボタンを設定.
		
		hitButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		hitButton.backgroundColor = UIColor.red;
		hitButton.layer.masksToBounds = true
		hitButton.setTitle("ヒット", for: UIControlState())
		hitButton.setTitleColor(UIColor.white, for: UIControlState())
		hitButton.setTitle("ヒット", for: UIControlState.highlighted)
		hitButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		hitButton.layer.cornerRadius = 20.0
		hitButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height/2-40)
		hitButton.addTarget(self, action: #selector(PVPScene.onClickHitButton(_:)), for: .touchUpInside)
		hitButton.addTarget(self, action: #selector(PVPScene.touchDownHitButton(_:)), for: .touchDown)
		hitButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		
		self.view!.addSubview(hitButton)
		
		
		standButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		standButton.backgroundColor = UIColor.red;
		standButton.layer.masksToBounds = true
		standButton.setTitle("スタンド", for: UIControlState())
		standButton.setTitleColor(UIColor.white, for: UIControlState())
		standButton.setTitle("スタンド", for: UIControlState.highlighted)
		standButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		standButton.layer.cornerRadius = 20.0
		standButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height/2+40)
		standButton.addTarget(self, action: #selector(PVPScene.onClickStandButton(_:)), for: .touchUpInside)
		standButton.addTarget(self, action: #selector(PVPScene.touchDownStandButton(_:)), for: .touchDown)
		standButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(standButton)
		
		//ターンを表示
		
		Label.text = "player1のターン"
		Label.fontSize = 45
		Label.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 20)
		self.addChild(Label)
		
		
		//BJの判定
		let j=Cards().judge(0)
		if j==5{
			ppLabel.text="Blackjack!"
			cpLabel.text="Blackjack!"
			draw()
			
		}else if j==3{
			ppLabel.text="Blackjack!"
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
			self.addChild(card[ccards[1]])
			
			//得点表示
			cpLabel.text=pccards.cp
			
			pwin()
		}else if j==4{
			card[0].run(SKAction.hide())	  //裏面カードを非表示にする
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
			self.addChild(card[ccards[1]])
			
			//得点表示
			cpLabel.text="Blackjack!"
			
			
			plose()
		}
		
	}
	
	
	
	
	func onClickHitButton(_ sender : UIButton){
		playcard.currentTime=0
		playcard.play()
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		if scounter==0{ //p1のターンで押されたとき
			let (pcards,pp)=Cards().hit(hcounter)
			
			//p1の手札追加
			card[pcards[2+hcounter]].position=CGPoint(x:cwidth/2+cwidth*CGFloat(2+hcounter),y:cheight/2)
			self.addChild(card[pcards[2+hcounter]])
			
			//得点を更新
			ppLabel.text=pp
			
			hcounter+=1
			
			//バストの判定
			let j=Cards().judge(1)
			if j==4{
				ppLabel.text! += " Bust!!!"
				plose()
				
				card[0].run(SKAction.hide())	  //p2の裏面カードを非表示にする
				
				//2枚目を表に向ける
				var ccards=Cards.ccards
				card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
				self.addChild(card[ccards[1]])
				
				//得点を表示する
				let (_,cp0)=Cards().getpoints()
				cpLabel.text=cp0
			}
		}else if scounter==1{	//p2のターン
			let (ccards,cp)=Cards().stand(hcounter+chcounter) //カードを引く
			
			
			//手札追加
			card[ccards[2+chcounter]].position=CGPoint(x:cwidth/2+cwidth*CGFloat(2+chcounter),y:frame.size.height-cheight/2)
			self.addChild(card[ccards[2+chcounter]])
			
			//得点を更新
			cpLabel.text=cp
			
			//引いた直後にバストの判定(ループ内)
			let j=Cards().judge(1)
			if j==3{
				cpLabel.text! += " Bust!!!"
				pwin()
				
			}
			chcounter+=1
		}
		
		//standボタンを押せるようにする
		standButton.isEnabled=true
		
	}
	
	func onClickStandButton(_ sender : UIButton){
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		if scounter==0{ //p2のターンへ移行
			playcard.currentTime=0
			playcard.play()	//裏返す音
			card[0].run(SKAction.hide())	  //裏面カードを非表示にする
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
			self.addChild(card[ccards[1]])
			
			//得点を表示する
			let (_,cp0)=Cards().getpoints()
			cpLabel.text=cp0
			
			scounter+=1
			
			Label.text="player2のターン"
			
		}else if scounter==1{
			//最終判定(ループ外)
			let j=Cards().judge(1)
			if j==0{
				draw()
			}else if j==1{
				pwin()
			}else if j==2{
				plose()
			}
			
			//初期化
			scounter=0
		}
		
		//hitボタンを押せるようにする
		hitButton.isEnabled=true
	}
	
	
	func pwin(){
		
		hitButton.isHidden=true
		standButton.isHidden=true
		
		
		
		Label.text = "Player1 win!"
		
		endofthegame()
	}
	
	func plose(){
		
		hitButton.isHidden=true
		standButton.isHidden=true
		
		
		
		Label.text = "Player2 win!"
		
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		hitButton.isHidden=true
		standButton.isHidden=true
		
		
		
		Label.text = "Draw"
		
		endofthegame()
	}
	
	func endofthegame(){
		// ボタンを生成.
		
		resetButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		resetButton.backgroundColor = UIColor.red;
		resetButton.layer.masksToBounds = true
		resetButton.setTitle("リプレイ", for: UIControlState())
		resetButton.setTitleColor(UIColor.white, for: UIControlState())
		resetButton.setTitle("リプレイ", for: UIControlState.highlighted)
		resetButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		resetButton.layer.cornerRadius = 20.0
		resetButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-20)
		resetButton.addTarget(self, action: #selector(PVPScene.onClickResetButton(_:)), for: .touchUpInside)
		resetButton.addTarget(self, action: #selector(PVPScene.touchDownResetButton(_:)), for: .touchDown)
		resetButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		
		self.view!.addSubview(resetButton)
		
		
		titleButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		titleButton.backgroundColor = UIColor.red;
		titleButton.layer.masksToBounds = true
		titleButton.setTitle("タイトルへ戻る", for: UIControlState())
		titleButton.setTitleColor(UIColor.white, for: UIControlState())
		titleButton.setTitle("タイトルへ戻る", for: UIControlState.highlighted)
		titleButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		titleButton.layer.cornerRadius = 20.0
		titleButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-70)
		titleButton.addTarget(self, action: #selector(PVPScene.onClickTitleButton(_:)), for: .touchUpInside)
		titleButton.addTarget(self, action: #selector(PVPScene.touchDownTitleButton(_:)), for: .touchDown)
		titleButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(titleButton)
		
	}
	
	func onClickResetButton(_ sender : UIButton){
		//クラス変数を初期化
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		Cards.cards=[Int](1...52)
		
		//ボタンを隠す
		resetButton.isHidden=true
		titleButton.isHidden=true
		
		let gameScene:PVPScene = PVPScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //PVPSceneに移動
	}
	
	func onClickTitleButton(_ sender : UIButton){
		//クラス変数を初期化
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		Cards.cards=[Int](1...52)
		
		//ボタンを隠す
		resetButton.isHidden=true
		titleButton.isHidden=true
		
		let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
	}
	
	//同時押し対策
	func touchDownHitButton(_ sender: UIButton){  //(disableされたボタンは外にドラッグして戻したときに表示がhilightされなくなる)
		standButton.isEnabled=false
	}
	func touchDownStandButton(_ sender: UIButton){
		hitButton.isEnabled=false
	}
	func touchDownTitleButton(_ sender: UIButton){
		resetButton.isEnabled=false
	}
	func touchDownResetButton(_ sender: UIButton){
		titleButton.isEnabled=false
	}
	
	func enableButtons(_ sender:UIButton){
		resetButton.isEnabled=true
		titleButton.isEnabled=true
		hitButton.isEnabled=true
		standButton.isEnabled=true
	}


}
