//
//  Netp2Scene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit
import GameKit

class Netp2Scene: SKScene {
	var card:[SKSpriteNode] = []	  //カードの画像(空の配列)
	let ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	let cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	var fpcardsc=2	//p1の手札の数(更新前)
	//ボタンを生成
	static let hitButton = UIButton()
	static let standButton = UIButton()
	static let resetButton=UIButton()
	static let titleButton=UIButton()
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンを表示→結果を表示
	
	
	var chcounter=0 //comがヒットした数
	
	let p1Label=SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,p2と表示
	let p2Label=SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	let nets=net()
	// lastを用意しておく
	var last:CFTimeInterval!
	
	var firstdraw=false
	var didchange=false
	var buttontapped=true
	
	
	
	override func didMove(to view: SKView) {
		
		
		
		let cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		//ラベルの設定をしておく
		
		p1Label.fontSize = cheight*20/138	//20はもともとの定数、138は7plusでのcheightの値
		p1Label.horizontalAlignmentMode = .left	//左寄せ
		p1Label.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*55/138)
		p1Label.text="P1"
		p1Label.fontColor=SKColor.blue
		addChild(p1Label)
		
		p2Label.fontSize = cheight*20/138
		p2Label.horizontalAlignmentMode = .left	//左寄せ
		p2Label.position = CGPoint(x:0, y:cheight+cheight*35/138)
		p2Label.text="P2"
		p2Label.fontColor=SKColor.red
		addChild(p2Label)
		
		ppLabel.fontSize = cheight*30/138
		ppLabel.horizontalAlignmentMode = .left	//左寄せ
		ppLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*30/138)
		addChild(ppLabel)
		
		cpLabel.fontSize = cheight*30/138
		cpLabel.horizontalAlignmentMode = .left
		cpLabel.position = CGPoint(x:0, y:cheight+cheight*5/138)
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
		
				
		
		
		
		
		// ボタンを設定.
		
		Netp2Scene.hitButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp2Scene.hitButton.backgroundColor = UIColor.red;
		Netp2Scene.hitButton.layer.masksToBounds = true
		Netp2Scene.hitButton.setTitle("ヒット", for: UIControlState())
		Netp2Scene.hitButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp2Scene.hitButton.setTitle("ヒット", for: UIControlState.highlighted)
		Netp2Scene.hitButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp2Scene.hitButton.setTitle("...", for: UIControlState.disabled)
		Netp2Scene.hitButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp2Scene.hitButton.layer.cornerRadius = 20.0
		Netp2Scene.hitButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height/2-40)
		Netp2Scene.hitButton.addTarget(self, action: #selector(PVPScene.onClickHitButton(_:)), for: .touchUpInside)
		Netp2Scene.hitButton.addTarget(self, action: #selector(PVPScene.touchDownHitButton(_:)), for: .touchDown)
		Netp2Scene.hitButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		Netp2Scene.hitButton.isHidden=true
		
		self.view!.addSubview(Netp2Scene.hitButton)
		
		
		Netp2Scene.standButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp2Scene.standButton.backgroundColor = UIColor.red;
		Netp2Scene.standButton.layer.masksToBounds = true
		Netp2Scene.standButton.setTitle("スタンド", for: UIControlState())
		Netp2Scene.standButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp2Scene.standButton.setTitle("スタンド", for: UIControlState.highlighted)
		Netp2Scene.standButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp2Scene.standButton.setTitle("...", for: UIControlState.disabled)
		Netp2Scene.standButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp2Scene.standButton.layer.cornerRadius = 20.0
		Netp2Scene.standButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height/2+40)
		Netp2Scene.standButton.addTarget(self, action: #selector(PVPScene.onClickStandButton(_:)), for: .touchUpInside)
	Netp2Scene.standButton.addTarget(self, action: #selector(PVPScene.touchDownStandButton(_:)), for: .touchDown)
		Netp2Scene.standButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		Netp2Scene.standButton.isHidden=true
		self.view!.addSubview(Netp2Scene.standButton)
		
		
		
		
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		
		let cheight = (view?.frame.height)!/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		// Called before each frame is rendered
		// lastが未定義ならば、今の時間を入れる。
		if last == nil{
			last = currentTime
		}
		if buttontapped==true{
			last=currentTime
			buttontapped=false
		}
		// 4秒おきに行う処理をかく。
		if last + 4 <= currentTime  {
			//サーバーから山札、手札を獲得
			
			nets.receiveData()
			if Cards.state=="break"{	  //breakを受信したら強制終了
				Netp2Scene.hitButton.isHidden=true
				Netp2Scene.standButton.isHidden=true
				Netp2Scene.resetButton.isHidden=true
				Netp2Scene.titleButton.isHidden=true
				let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
				let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
				gameScene.scaleMode = SKSceneScaleMode.fill
				self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
			}
			
			print(Cards.state)
		
			Netp2Scene.hitButton.isEnabled=true
			Netp2Scene.standButton.isEnabled=true
			Netp2Scene.resetButton.isEnabled=true
			Netp2Scene.titleButton.isEnabled=true
			
			
			let pcardsc=Cards.pcards.count
			if firstdraw==false && Cards.state=="p1turn"{
				//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
				let pcards:[Int]=Cards.pcards
				let ccards:[Int]=Cards.ccards
				let (pp,cp)=Cards().getpoints()
				
				
				//1p（敵）の各手札を表示
				for (index,value) in pcards.enumerated(){
					card[value].position=CGPoint(x:cwidth/2+cwidth*CGFloat(index),y:frame.size.height-cheight/2)
					self.addChild(card[value])
				}
				
				//2pの1枚目は表,2枚目は裏向き
				card[ccards[0]].position=CGPoint(x:cwidth/2,y:cheight/2)
				card[0].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
				self.addChild(card[ccards[0]])
				self.addChild(card[0])
				
				//敵の得点表示
				ppLabel.text=pp
				//ターンを表示
				
				Label.text = "player1のターン"
				Label.fontSize = 45
				Label.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 20)
				self.addChild(Label)
				
				//BJの判定
				let j=Cards().judge(0)
				if j==5{
					//2枚目を表に向ける
					var ccards=Cards.ccards
					card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
					self.addChild(card[ccards[1]])
					ppLabel.text="Blackjack!"
					cpLabel.text="Blackjack!"
					draw()
					
				}else if j==3{
					ppLabel.text="Blackjack!"
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
					self.addChild(card[ccards[1]])
					
					//得点表示
					cpLabel.text=cp
					
					pwin()
				}else if j==4{
					card[0].run(SKAction.hide())	  //裏面カードを非表示にする
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
					self.addChild(card[ccards[1]])
					
					//得点表示
					cpLabel.text="Blackjack!"
					
					
					plose()
				}
				
				firstdraw=true
			}else if (pcardsc != fpcardsc) && (Cards.state != "end") && (Cards.state != "start"){//更新(startはまだ配った手札が来てない状態、endは手札がからの状態)
				let pcards:[Int]=Cards.pcards
				
				let (pp,_)=Cards().getpoints()
				//1p（敵）の各手札を表示
				
				card[pcards[pcardsc-1]].position=CGPoint(x:cwidth/2+cwidth*CGFloat(pcardsc-1),y:frame.size.height-cheight/2)
				self.addChild(card[pcards[pcardsc-1]])
				
				//敵の得点表示
				ppLabel.text=pp
				fpcardsc+=1
				
				//敵のbustの判定
				let j=Cards().judge(1)
				if j==4{
					ppLabel.text! += " Bust!!!"
					plose()
					
					card[0].run(SKAction.hide())	  //p2の裏面カードを非表示にする
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
					self.addChild(card[ccards[1]])
					
					//得点を表示する
					let (_,cp0)=Cards().getpoints()
					cpLabel.text=cp0
				}
				
			}
			if Cards.state=="p2turn"&&didchange==false{
				Netp2Scene.hitButton.isHidden=false
				Netp2Scene.standButton.isHidden=false
				card[0].run(SKAction.hide())	  //p2の裏面カードを非表示にする
				
				//2枚目を表に向ける
				var ccards=Cards.ccards
				card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
				self.addChild(card[ccards[1]])
				
				//得点を表示する
				let (_,cp0)=Cards().getpoints()
				cpLabel.text=cp0
				Label.text="player2のターン"
				
				didchange=true
				
			}
			
			
			
			last = currentTime
		}
		
		
		
	}
	
	
	func onClickHitButton(_ sender : UIButton){
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		let hcounter=Cards.pcards.count-2
		
		let (ccards,cp)=Cards().stand(hcounter+chcounter) //カードを引く
		
		
		//手札追加
		card[ccards[2+chcounter]].position=CGPoint(x:cwidth/2+cwidth*CGFloat(2+chcounter),y:cheight/2)
		self.addChild(card[ccards[2+chcounter]])
		
		//得点を更新
		cpLabel.text=cp
		
		nets.sendData()
		
		//引いた直後にバストの判定(ループ内)
		let j=Cards().judge(1)
		if j==3{
			cpLabel.text! += " Bust!!!"
			pwin()
			
		}
		chcounter+=1
		
		
		Netp2Scene.standButton.isEnabled=true
		
		//1度、通信完了までボタンを押せないようにする
		Netp2Scene.hitButton.isEnabled=false
		Netp2Scene.standButton.isEnabled=false
		Netp2Scene.resetButton.isEnabled=false
		Netp2Scene.titleButton.isEnabled=false
		buttontapped=true
		
		
	}
	
	func onClickStandButton(_ sender : UIButton){
		Cards.state="judge"
		nets.sendData()
		
		//最終判定(ループ外)
		let j=Cards().judge(1)
		if j==0{
			draw()
		}else if j==1{
			pwin()
		}else if j==2{
			plose()
		}
		
		
		//1度、通信完了までボタンを押せないようにする
		Netp2Scene.hitButton.isEnabled=false
		Netp2Scene.standButton.isEnabled=false
		Netp2Scene.resetButton.isEnabled=false
		Netp2Scene.titleButton.isEnabled=false
		
		Netp2Scene.hitButton.isHidden=true
		Netp2Scene.standButton.isHidden=true
		
		buttontapped=true
		
	}
	
	
	func pwin(){
		
		Netp2Scene.hitButton.isHidden=true
		Netp2Scene.standButton.isHidden=true
		
		
		
		Label.text = "Player1 win!"
		
		endofthegame()
	}
	
	func plose(){
		
	Netp2Scene.hitButton.isHidden=true
	Netp2Scene.standButton.isHidden=true
		
		
		
		Label.text = "Player2 win!"
		
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		Netp2Scene.hitButton.isHidden=true
		Netp2Scene.standButton.isHidden=true
		
		
		
		Label.text = "Draw"
		
		endofthegame()
	}
	
	func endofthegame(){
		chcounter=0
		fpcardsc=2	//p1の手札の数(更新前)
		Netp2Scene.titleButton.isEnabled=false
		Netp2Scene.resetButton.isEnabled=false
		
		
		// ボタンを生成.
		
		Netp2Scene.resetButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp2Scene.resetButton.backgroundColor = UIColor.red;
		Netp2Scene.resetButton.layer.masksToBounds = true
		Netp2Scene.resetButton.setTitle("リプレイ", for: UIControlState())
		Netp2Scene.resetButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp2Scene.resetButton.setTitle("リプレイ", for: UIControlState.highlighted)
		Netp2Scene.resetButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp2Scene.resetButton.setTitle("...", for: UIControlState.disabled)
		Netp2Scene.resetButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp2Scene.resetButton.layer.cornerRadius = 20.0
		Netp2Scene.resetButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-20)
		Netp2Scene.resetButton.addTarget(self, action: #selector(PVPScene.onClickResetButton(_:)), for: .touchUpInside)
		Netp2Scene.resetButton.addTarget(self, action: #selector(PVPScene.touchDownResetButton(_:)), for: .touchDown)
		Netp2Scene.resetButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		Netp2Scene.resetButton.isHidden=false
		self.view!.addSubview(Netp2Scene.resetButton)
		
		
		Netp2Scene.titleButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp2Scene.titleButton.backgroundColor = UIColor.red;
		Netp2Scene.titleButton.layer.masksToBounds = true
		Netp2Scene.titleButton.setTitle("タイトルへ戻る", for: UIControlState())
		Netp2Scene.titleButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp2Scene.titleButton.setTitle("タイトルへ戻る", for: UIControlState.highlighted)
		Netp2Scene.titleButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp2Scene.titleButton.setTitle("...", for: UIControlState.disabled)
		Netp2Scene.titleButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp2Scene.titleButton.layer.cornerRadius = 20.0
		Netp2Scene.titleButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-70)
		Netp2Scene.titleButton.addTarget(self, action: #selector(PVPScene.onClickTitleButton(_:)), for: .touchUpInside)
		Netp2Scene.titleButton.addTarget(self, action: #selector(PVPScene.touchDownTitleButton(_:)), for: .touchDown)
		Netp2Scene.titleButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		Netp2Scene.resetButton.isHidden=false
		self.view!.addSubview(Netp2Scene.titleButton)
		
		
		
	}
	
	func onClickResetButton(_ sender : UIButton){//
		if Cards.state=="p1turn"{   //endofthegameに入れると、カードの表示前に初期化してしまう！
			Cards.state="end"
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards=[Int](1...52)
			nets.sendData() //受け手側が送るようにする
		}

		//ボタンを隠す
		Netp2Scene.resetButton.isHidden=true
		Netp2Scene.titleButton.isHidden=true
		
		let gameScene:waitingScene = waitingScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //waitingSceneに移動
	}
	
	func onClickTitleButton(_ sender : UIButton){
		if Cards.state=="p1turn"{   //endofthegameに入れると、カードの表示前に初期化してしまう！
			Cards.state="end"
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards=[Int](1...52)
			nets.sendData() //受け手側が送るようにする
		}
		

		
		//ボタンを隠す
		Netp2Scene.resetButton.isHidden=true
		Netp2Scene.titleButton.isHidden=true
		
		let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
	}
	
	//同時押し対策
	func touchDownHitButton(_ sender: UIButton){  //(disableされたボタンは外にドラッグして戻したときに表示がhilightされなくなる)
		Netp2Scene.standButton.isEnabled=false
	}
	func touchDownStandButton(_ sender: UIButton){
		Netp2Scene.hitButton.isEnabled=false
	}
	func touchDownTitleButton(_ sender: UIButton){
		Netp2Scene.resetButton.isEnabled=false
	}
	func touchDownResetButton(_ sender: UIButton){
		Netp2Scene.titleButton.isEnabled=false
	}
	
	func enableButtons(_ sender:UIButton){
		Netp2Scene.resetButton.isEnabled=true
		Netp2Scene.titleButton.isEnabled=true
		Netp2Scene.hitButton.isEnabled=true
		Netp2Scene.standButton.isEnabled=true
	}


}
