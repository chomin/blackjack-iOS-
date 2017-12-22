
//
//  Buttons.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/25.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit


extension GameScene{//ボタンに関する拡張
	
	func setButtons(frame_height: CGFloat, frame_width: CGFloat){
		
		let cheight = frame_height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		
		hitButton.frame = CGRect(x: 0,y: 0,width: cheight*200/138,height: cheight*40/138)
		hitButton.backgroundColor = UIColor.red
		hitButton.layer.masksToBounds = true
		hitButton.setTitle("ヒット", for: UIControlState())
		hitButton.setTitleColor(UIColor.white, for: UIControlState())
		hitButton.setTitle("ヒット", for: UIControlState.highlighted)
		hitButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		hitButton.setTitle("...", for: UIControlState.disabled)
		hitButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		hitButton.layer.cornerRadius = 20.0
		hitButton.layer.position = CGPoint(x: frame_width-cheight*100/138, y:frame_height/2-cheight*40/138)
		hitButton.addTarget(self, action: #selector(onClickHitButton(_:)), for: .touchUpInside)
		hitButton.addTarget(self, action: #selector(touchDownHitButton(_:)), for: .touchDown) //一旦standボタンを押せないようにする
		hitButton.addTarget(self, action: #selector(enableButtons(_:)), for: .touchUpOutside)	//押せるように戻す
		
		if Game.mode == .netp2{
			hitButton.isHidden = true
		}else{
			hitButton.isHidden = false
		}
		
		
		standButton.frame = CGRect(x: 0,y: 0,width: cheight*200/138,height: cheight*40/138)
		standButton.backgroundColor = UIColor.red;
		standButton.layer.masksToBounds = true
		standButton.setTitle("スタンド", for: UIControlState())
		standButton.setTitleColor(UIColor.white, for: UIControlState())
		standButton.setTitle("スタンド", for: UIControlState.highlighted)
		standButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		standButton.setTitle("...", for: UIControlState.disabled)
		standButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		standButton.layer.cornerRadius = 20.0
		standButton.layer.position = CGPoint(x: frame_width-cheight*100/138, y:frame_height/2+cheight*40/138)
		standButton.addTarget(self, action: #selector(onClickStandButton(_:)), for: .touchUpInside)
		standButton.addTarget(self, action: #selector(touchDownStandButton(_:)), for: .touchDown)
		standButton.addTarget(self, action: #selector(enableButtons(_:)), for: .touchUpOutside)
						
		if Game.mode == .netp2{
			standButton.isHidden = true
		}else{
			standButton.isHidden = false
		}
		
		resetButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		resetButton.backgroundColor = UIColor.red;
		resetButton.layer.masksToBounds = true
		resetButton.setTitle("リプレイ", for: UIControlState())
		resetButton.setTitleColor(UIColor.white, for: UIControlState())
		resetButton.setTitle("リプレイ", for: UIControlState.highlighted)
		resetButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		resetButton.setTitle("...", for: UIControlState.disabled)
		resetButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		resetButton.layer.cornerRadius = 20.0
		resetButton.layer.position = CGPoint(x: frame_width-100, y:frame_height-20)
		resetButton.addTarget(self, action: #selector(onClickResetButton(_:)), for: .touchUpInside)
		resetButton.addTarget(self, action: #selector(touchDownResetButton(_:)), for: .touchDown)
		resetButton.addTarget(self, action: #selector(enableButtons(_:)), for: .touchUpOutside)
		
		resetButton.isHidden = true
		
		titleButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		titleButton.backgroundColor = UIColor.red;
		titleButton.layer.masksToBounds = true
		titleButton.setTitle("タイトルへ戻る", for: UIControlState())
		titleButton.setTitleColor(UIColor.white, for: UIControlState())
		titleButton.setTitle("タイトルへ戻る", for: UIControlState.highlighted)
		titleButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		titleButton.setTitle("...", for: UIControlState.disabled)
		titleButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		titleButton.layer.cornerRadius = 20.0
		titleButton.layer.position = CGPoint(x: frame_width-100, y:frame_height-70)
		titleButton.addTarget(self, action: #selector(onClickTitleButton(_:)), for: .touchUpInside)
		titleButton.addTarget(self, action: #selector(touchDownTitleButton(_:)), for: .touchDown)
		titleButton.addTarget(self, action: #selector(enableButtons(_:)), for: .touchUpOutside)
		
		titleButton.isHidden = true

		
		self.view!.addSubview(hitButton)
		self.view!.addSubview(standButton)
		self.view!.addSubview(resetButton)
		self.view!.addSubview(titleButton)
	}

	
	@objc func onClickHitButton(_ sender : UIButton){
		hitButton.isEnabled=false
		standButton.isEnabled=false
		
//		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
//		let cwidth = cheight*2/3
		
		self.isPaused=true  //updateによる受信防止
		
		if Game.mode == .com || Game.mode == .scom {
			
//			let (pcards,_) =
			
			Game().pHit()
			
			//Aの得点の確認
			checkA()
			

			
			//バストの判定
			var j = Game().judge(1)
			
			//ルシフェル探し
			if j == 4{
				//バスト時効果
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.bustEffect(bustPlayer: .p1)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.bustEffect(bustPlayer: .p1)
					}
				}
//				checkLucifer(player: .p1)
				j = Game().judge(1)
			}
			
			//バストしていたらBP消費
			while j == 4{

				if Game.pBP>0 {
					Game.pBP -= 1
					
					let removecard = Game.pcards.last!	//消す前に保存
					Game.pcards.removeLast()
					GameScene.makeUseBPResevation(hide: [removecard], BPLabel: (String(Game.pBP),nil)) //得点計算のためremoveLastの後
//					hcounter -= 1
					
					j = Game().judge(1)
					continue	//まだバストしていたらさらにBPを消費
				}else{
					plose()
					
					//2枚目を表に向ける
					var ccards = Game.ccards
					if ccards.count>0{//バハで消えてないか確認
						if ccards.last!.isReversed{
							if ccards[1].cardNum < 53{
								GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
							}else if let SC = ccards[1] as? SpecialCard{
								//裏を隠してファンファーレ
								GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [GameScene.backCard], pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP:nil)))
								Game.firstDealed = false
								SC.fanfare(cardPlace: .com, index: 1)
								//							let i = getSpecialEnteringSoundType(card: ccards[1].card)
								//
								//							makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
							}
						}
					}
					//敵の得点を表示
					cpLabel.isHidden = false
					
					break
				}
			}
			
//			hcounter += 1
			
		}else if Game.mode == .pvp{
			if scounter == 0{ //p1のターンで押されたとき
//				let (pcards,_) =
				
				Game().pHit()
				
				//Aの得点の確認
				checkA()
			
				//バストの判定
				let j = Game().judge(1)
				
				if j == 4{
					plose()
					
					//2枚目を表に向ける
					var ccards = Game.ccards
					if ccards[1].cardNum < 53{
						GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
					}else{
						//TODO
//						let i = getSpecialEnteringSoundType(card: ccards[1].card)
//
//						makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					}
					
					//得点を表示する
					cpLabel.isHidden = false
				}
			}else if scounter == 1{	//p2のターン
				let (ccards,_) = Game().cHit() //カードを引く
				
				
				//Aの得点の確認
				checkA()
				
				//手札追加&得点更新
				GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(ccards.count-1), y: frame.size.height-GameScene.cheight/2, card: ccards.last!)
				
				
				
				//引いた直後にバストの判定(ループ内)
				let j = Game().judge(1)
				if j == 3{
					pwin()
					
				}
//				chcounter += 1
			}
			
		}else if Game.mode == .netp1{
			repeat { //最新まで受信(受信防止しているが、後で更新時に前のデータを受信するとバグる）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest == false
			
//			let (pcards,_) =
//
		    Game().pHit()
			
			//Aの得点の確認
			checkA()
			
			//p1の手札追加&得点の更新
//			GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(pcards.count-1), y: GameScene.cheight/2, card: pcards.last!)
			
//			hcounter += 1
			
			nets.sendData()
			
			//バストの判定
			let j = Game().judge(1)
			if j == 4{
				plose()
				
				//2枚目を表に向ける
				var ccards = Game.ccards
				if ccards[1].cardNum<53{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}else{
					//TODO
//					let i = getSpecialEnteringSoundType(card: ccards[1].card)
//
//					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [backCard])
				}
				
				//得点を表示する
				cpLabel.isHidden = false
			}
		}else{//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest == false
			
			let (ccards,_)=Game().cHit() //カードを引く
			
			//Aの得点の確認
			checkA()
			
			//手札追加&得点更新
			GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(ccards.count-1), y: GameScene.cheight/2, card: ccards.last!)
			
			nets.sendData()
			
			//引いた直後にバストの判定(ループ内)
			let j = Game().judge(1)
			if j == 3{
				pwin()
			}
			//			chcounter += 1
		}
		self.isPaused=false
	}
	
	@objc func onClickStandButton(_ sender : UIButton){
		self.isPaused = true  //updateによる受信防止
		
		if Game.mode != .netp2 && (Game.mode != .pvp || scounter == 0){
			//2枚目を表に向ける
			var ccards = Game.ccards
			if ccards.count>0 {//バハで消えてないか確認
				if ccards.last!.isReversed{//バハで消えてないか確認
					if ccards[1].cardNum<53{
						
						GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
						
					}else if let SC = ccards[1] as? SpecialCard{//特殊カード
						
						//まず裏を隠し、登場音とともに登場させる
						GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [GameScene.backCard], pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP:nil)))
						SC.fanfare(cardPlace: .com, index: 1)
						
						
					}
					//ドロー時効果
					for j in Game.pcards{//場にある分の効果を確認
						if let SC2 = j as? SpecialCard{
							SC2.drawEffect(drawPlayer: .com)
						}
					}
					for j in Game.ccards{//場にある分の効果を確認
						if let SC2 = j as? SpecialCard{
							SC2.drawEffect(drawPlayer: .com)
						}
					}
					
				}
			}
			//得点を表示する
			cpLabel.isHidden = false
		}
		
		if Game.mode == .com || Game.mode == .scom {
			
			centerLabel.text = "comのターン"
			
			var j = Game().judge(1)
			while j != 3{//バストしてない間
				//引く前に次に引くべきかを判定
				let (ppoint,cpoint,_,_) = Game().calculatepoints()
				if cpoint.noA>16 && cpoint.noA>ppoint.noA{//17以上でcomが勝ってるとき
					break
				}else if cpoint.noA>16 && Game.cBP==0{//17以上でBPがもうないとき
					break
				}
				
				Game().cHit()
				
				//Aの得点の確認
				checkA()

				//引いた直後にバストの判定(ループ内)
				j = Game().judge(1)
				
				//ルシフェル探し
				if j == 3{
					//バスト時効果
					for j in Game.pcards{//場にある分の効果を確認
						if let SC2 = j as? SpecialCard{
							SC2.bustEffect(bustPlayer: .com)
						}
					}
					for j in Game.ccards{//場にある分の効果を確認
						if let SC2 = j as? SpecialCard{
							SC2.bustEffect(bustPlayer: .com)
						}
					}
//					checkLucifer(player: .com)
					j = Game().judge(1)
				}
				
				while j == 3{
					if Game.cBP>0 && Game.mode == .scom{//シャドウジャックのみ
						Game.cBP -= 1	//--は抹消された...
						let removecard = Game.ccards.last!//消す前に保存
						Game.ccards.removeLast()
						
						GameScene.makeUseBPResevation(hide: [removecard], BPLabel: (nil,String(Game.cBP)))//得点計算のためremoveLastの後
						scounter-=1
						
						j=Game().judge(1)
						continue
					}else{
						pwin()
						break//一番内側からしか抜けられない！
					}
				}
				scounter+=1
			}
			//最終判定(ループ外)
			j=Game().judge(1)
			if j==0{
				draw()
			}else if j==1{
				pwin()
			}else if j==2{
				plose()
			}
		}else if Game.mode == .pvp {
			if scounter == 0{ //p2のターンへ移行
				
				scounter+=1
				
				centerLabel.text="P2のターン"
				
			}else if scounter == 1{
				//最終判定(ループ外)
				let j=Game().judge(1)
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
			
		}else if Game.mode == .netp1 {
			repeat { //最新まで受信
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			centerLabel.text="相手のターン"
			
			Game.state = .p2turn
			nets.sendData()
			
			hitButton.isHidden=true
			standButton.isHidden=true
			self.isPaused=false
			
		}else {//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			Game.state = .judge
			nets.sendData()
			Game.state = .end	  //今後の受信を停止
			
			//最終判定(ループ外)
			let j=Game().judge(1)
			if j==0{
				
				draw()
			}else if j==1{
				pwin()
			}else if j==2{
				plose()
			}
			
			hitButton.isHidden=true
			standButton.isHidden=true
		}
		//hitボタンを押せるようにする
		hitButton.isEnabled=true
		self.isPaused=false
		
	}
	
	
	@objc func onClickResetButton(_ sender : UIButton){
		if Game.mode == .pvp || Game.mode == .com || Game.mode == .scom{
			//クラス変数を初期化
			Game.pcards.removeAll()
			Game.deckCards.removeAll()
			Game.ccards.removeAll()
		}
		//ボタンを隠す
		resetButton.isHidden=true
		titleButton.isHidden=true
		
		if Game.mode == .pvp || Game.mode == .com || Game.mode == .scom{
			let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
			let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
			gameScene.scaleMode = SKSceneScaleMode.fill
			self.view!.presentScene(gameScene, transition: transition) //GameSceneに移動
		}else{//net系
			let gameScene:waitingScene = waitingScene(size: self.view!.bounds.size) // create your new scene
			let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
			gameScene.scaleMode = SKSceneScaleMode.fill
			self.view!.presentScene(gameScene, transition: transition) //waitingSceneに移動
			
		}
	}
	
	@objc func onClickTitleButton(_ sender : UIButton){
		if Game.mode == .pvp || Game.mode == .com || Game.mode == .scom{
			//クラス変数を初期化
			Game.pcards.removeAll()
			Game.deckCards.removeAll()
			Game.ccards.removeAll()
		}
		
		//ボタンを隠す
		resetButton.isHidden=true
		titleButton.isHidden=true
		
		let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
	}
	
	//同時押し対策
	@objc func touchDownHitButton(_ sender: UIButton){  //(disableされたボタンは外にドラッグして戻したときに表示がhilightされなくなる)
		standButton.isEnabled = false
		hitButton.isEnabled = false
	}
	@objc func touchDownStandButton(_ sender: UIButton){
		hitButton.isEnabled = false
	}
	@objc func touchDownTitleButton(_ sender: UIButton){
		resetButton.isEnabled = false
	}
	@objc func touchDownResetButton(_ sender: UIButton){
		titleButton.isEnabled = false
	}
	@objc func enableButtons(_ sender:UIButton){
		resetButton.isEnabled = true
		titleButton.isEnabled = true
		hitButton.isEnabled = true
		standButton.isEnabled = true
	}
	
}
