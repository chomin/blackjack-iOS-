
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
		
		if Cards.mode == .netp2{
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
						
		if Cards.mode == .netp2{
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
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		self.isPaused=true  //updateによる受信防止
		
		if Cards.mode == .com || Cards.mode == .scom {
			let ccards=Cards.ccards	  //バハによる除去前の敵の手札
			var (pcards,_)=Cards().hit()
			
			//Aの得点の確認
			checkA()
			
			//手札追加
			if pcards[2+hcounter].0<53{//引いたのがトランプのとき
				for i in Cards.pcards{//アリスの確認
					if i.card == 57 || i.card == 62 || i.card == 63{
						Cards.pcards[2+hcounter].point += 1
						tPointLabel[Cards.pcards[2+hcounter].card-1].fontColor = SKColor.orange
						tPointLabel[Cards.pcards[2+hcounter].card-1].text = String(Cards.pcards[2+hcounter].point)
					}
				}
				
				makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)
			}else if pcards[2+hcounter].0 == 54 || pcards[2+hcounter].0 == 58 || pcards[2+hcounter].0 == 59 {//オリヴィエ
				Cards.pBP = 3
				makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0, BPLabel: ("3",nil))
			}else if pcards[2+hcounter].0 == 57 || pcards[2+hcounter].0 == 62 || pcards[2+hcounter].0 == 63{//アリス
				var changeTPointLabels:[(index:Int,value:String,color:UIColor?)]=[]
				for (index,value) in Cards.pcards.enumerated(){
					if value.card<53{//トランプの得点を増やす
						Cards.pcards[index].point += 1
						changeTPointLabels.append((value.card-1,String(Cards.pcards[index].point),SKColor.orange))
					}else{
						//特殊カードの攻撃、体力を増やす
					}
				}
				makeAliceResevation(x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0, tPointLabel: changeTPointLabels)
			}else{
				let i = getSpecialEnteringSoundType(card: pcards[2+hcounter].0)
				
				makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)//特殊カードの表示
				if pcards[2+hcounter].0 == 55 || pcards[2+hcounter].0 == 60 || pcards[2+hcounter].0 == 61{//バハ
					hcounter = -2
					scounter = -2 //敵の手札も消える
					var remove = [0]
					for i in pcards{
						remove.append(i.0)
					}
					for i in ccards{
						remove.append(i.0)
					}
					
					//全カードの除去&バハを再び表示
					Cards.pcards.removeAll()
					Cards.ccards.removeAll()
					Cards.pcards.append((55,10))
					makeHideAndPaintResevation(sound: .br, x: cwidth/2, y: cheight/2, card: 55, hide: remove)//再表示は現状55にしておく
					
				}
			}
			
			
			
			//バストの判定
			var j = Cards().judge(1)
			
			//ルシフェル探し
			if j == 4{
				checkLucifer(player: .p1)
				j = Cards().judge(1)
			}
			
			//バストしていたらBP消費
			while j == 4{

				if Cards.pBP>0 {
					Cards.pBP -= 1	//--は抹消された...
					
					let removecard = Cards.pcards.last!.card	//消す前に保存
					Cards.pcards.removeLast()
					makeUseBPResevation(hide: [removecard], BPLabel: (String(Cards.pBP),nil)) //得点計算のためremoveLastの後
					hcounter -= 1
					
					j = Cards().judge(1)
					continue	//まだバストしていたらさらにBPを消費
				}else{
					plose()
					
					//2枚目を表に向ける
					var ccards = Cards.ccards
					if ccards.count>0{//バハで消えてないか確認
						if ccards[1].card<53{
							makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
						}else{
							let i = getSpecialEnteringSoundType(card: ccards[1].card)
							
							makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
						}
					}
					//敵の得点を表示
					cpLabel.isHidden = false
					
					break
				}
			}
			
			hcounter += 1
			
		}else if Cards.mode == .pvp{
			if scounter == 0{ //p1のターンで押されたとき
				let (pcards,_)=Cards().hit()
				
				//Aの得点の確認
				checkA()
				
				//p1の手札追加&得点の更新
				makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)
				
				hcounter += 1
				
				//バストの判定
				var j = Cards().judge(1)
				
				//ルシフェル探し
				if j == 4{
					checkLucifer(player: .p1)
					j = Cards().judge(1)
				}
				
				if j == 4{
					plose()
					
					//2枚目を表に向ける
					var ccards = Cards.ccards
					if ccards[1].card<53{
						makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					}else{
						let i = getSpecialEnteringSoundType(card: ccards[1].card)
						
						makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					}
					
					//得点を表示する
					cpLabel.isHidden = false
				}
			}else if scounter == 1{	//p2のターン
				let (ccards,_) = Cards().stand() //カードを引く
				
				
				//Aの得点の確認
				checkA()
				
				//手札追加&得点更新
				makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(2+chcounter), y: frame.size.height-cheight/2, card: ccards[2+chcounter].0)
				
				
				
				//引いた直後にバストの判定(ループ内)
				let j = Cards().judge(1)
				if j == 3{
					pwin()
					
				}
				chcounter += 1
			}
			
		}else if Cards.mode == .netp1{
			repeat { //最新まで受信(受信防止しているが、後で更新時に前のデータを受信するとバグる）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest == false
			
			let (pcards,_) = Cards().hit()
			
			//Aの得点の確認
			checkA()
			
			//p1の手札追加&得点の更新
			makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)
			
			hcounter += 1
			
			nets.sendData()
			
			//バストの判定
			let j = Cards().judge(1)
			if j == 4{
				plose()
				
				//2枚目を表に向ける
				var ccards = Cards.ccards
				if ccards[1].card<53{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}else{
					
					let i = getSpecialEnteringSoundType(card: ccards[1].card)
					
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
				
				//得点を表示する
				cpLabel.isHidden = false
			}
		}else{//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest == false
			
			let (ccards,_)=Cards().stand() //カードを引く
			
			//Aの得点の確認
			checkA()
			
			//手札追加&得点更新
			makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(2+chcounter), y: cheight/2, card: ccards[2+chcounter].0)
			
			nets.sendData()
			
			//引いた直後にバストの判定(ループ内)
			let j = Cards().judge(1)
			if j == 3{
				pwin()
			}
			chcounter += 1
		}
		self.isPaused=false
	}
	
	@objc func onClickStandButton(_ sender : UIButton){
		self.isPaused = true  //updateによる受信防止
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		if Cards.mode != .netp2{
			//2枚目を表に向ける
			var ccards = Cards.ccards
			if ccards.count>0{//バハで消えてないか確認
				if ccards[1].card<53{
					
					if Cards.ccards[0].card==57 || Cards.ccards[0].card==62 || Cards.ccards[0].card==63{//アリスの確認
						Cards.ccards[1].point += 1
						tPointLabel[ccards[1].card-1].fontColor = SKColor.orange
						tPointLabel[ccards[1].card-1].text = String(Cards.ccards[1].point)
					}
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					
				}else{//特殊カード
					
					//まず裏を隠し、登場音とともに登場させる
					let i = getSpecialEnteringSoundType(card: ccards[1].card)
					
					if ccards[1].card == 57 || ccards[1].card == 62 || ccards[1].card == 63{//アリス(得点更新の関係でこの位置)
						if ccards[0].card<53{//トランプの得点を増やす
							Cards.ccards[0].point += 1
							tPointLabel[ccards[0].card-1].fontColor = SKColor.orange
							tPointLabel[ccards[0].card-1].text = String(Cards.ccards[0].point)
						}else{
							//特殊カードの攻撃、体力を増やす
						}
					}
					
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					
					//各特殊能力の処理（登場音は済なので不要）
					if ccards[1].card == 55 || ccards[1].0 == 60 || ccards[1].0 == 61{//バハ
						let pcards=Cards.pcards
						scounter = -1
						var remove:[Int] = []
						for i in pcards{
							remove.append(i.card)
						}
						for i in ccards{
							remove.append(i.card)
						}
						
						Cards.pcards.removeAll()
						Cards.ccards.removeAll()
						Cards.ccards.append((55,10))
						makeHideAndPaintResevation(sound: .br, x: cwidth/2, y: frame.size.height-cheight/2, card: 55, hide: remove)
						
					}else if ccards[1].card == 54 || ccards[1].0 == 58 || ccards[1].0 == 59{//オリヴィエ
						Cards.cBP = 3
						resevation.append((sound: .BP3, x: nil, y: nil, card: nil, hide: [], pointLabels: (pp: nil, cp: nil), tPointLabels: [], BPLabels: (pBP: nil, cBP: "3")))
					}
				}
			}
			//得点を表示する
			cpLabel.isHidden = false
		}
		
		if Cards.mode == .com || Cards.mode == .scom {
			
			centerLabel.text = "comのターン"
			
			var j = Cards().judge(1)
			while j != 3{//バストしてない間
				//引く前に次に引くべきかを判定
				let (ppoint,cpoint,_,_) = Cards().calculatepoints()
				if cpoint.noA>16 && cpoint.noA>ppoint.noA{//17以上でcomが勝ってるとき
					break
				}else if cpoint.noA>16 && Cards.cBP==0{//17以上でBPがもうないとき
					break
				}
				
				let pcards = Cards.pcards
				var (ccards,_) = Cards().stand()
				
				//Aの得点の確認
				checkA()
//				(_,cpoint,_,_)=Cards().calculatepoints()
//				for (index,value) in Cards.ccards.enumerated(){
//					if value.card<53{//トランプ限定
//						if value.point==1 && cpoint.inA<22{
//							Cards.ccards[index].point+=10
//							tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
//							break	  //二枚目以降は更新しない
//						}
//						if value.card%13==1 && value.point>9 && cpoint.noA>21{
//							Cards.ccards[index].point-=10
//							tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
//							break //後に直すべきAはないはず
//						}
//					}
//				}
//
				//手札追加&得点更新
				if ccards[2+scounter].0 < 53{
					for i in Cards.ccards{//アリスの確認
						if i.card==57 || i.card==62 || i.card==63{
							Cards.ccards[2+scounter].point += 1
							tPointLabel[Cards.ccards[2+scounter].card-1].fontColor = .orange
							tPointLabel[Cards.ccards[2+scounter].card-1].text = String(Cards.ccards[2+scounter].point)
							
						}
					}
					
					makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0)
					
					
				}else if ccards[2+scounter].0==54 || ccards[2+scounter].0==58 || ccards[2+scounter].0==59{//オリヴィエ
					Cards.cBP=3
					makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0, BPLabel: (nil,"3"))
				}else if ccards[2+scounter].0==57 || ccards[2+scounter].0==62 || ccards[2+scounter].0==63{//アリス
					
					var changeTPointLabels:[(index:Int,value:String,color:UIColor?)]=[]
					for (index,value) in Cards.ccards.enumerated(){
						if value.card<53{//トランプの得点を増やす
							Cards.ccards[index].point+=1
							changeTPointLabels.append((value.card-1,String(Cards.ccards[index].point),SKColor.orange))
						}else{
							//特殊カードの攻撃、体力を増やす
						}
					}
					makeAliceResevation(x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0, tPointLabel: changeTPointLabels)
				}else{//その他の特殊カード
					let i = getSpecialEnteringSoundType(card: ccards[2+scounter].0)
					
					makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0)
					if ccards[2+scounter].0==55 || ccards[2+scounter].0==60 || ccards[2+scounter].0==61{//バハ
						scounter = -2
						var remove:[Int]=[]
						for i in pcards{
							remove.append(i.card)
						}
						for i in ccards{
							remove.append(i.0)
						}
						Cards.pcards.removeAll()
						Cards.ccards.removeAll()
						Cards.ccards.append((55,10))
						makeHideAndPaintResevation(sound: .br, x: cwidth/2, y: frame.size.height-cheight/2, card: 55, hide: remove)
						
						
					}
				}
				
				//引いた直後にバストの判定(ループ内)
				j = Cards().judge(1)
				
				//ルシフェル探し
				if j == 3{
					checkLucifer(player: .com)
					j = Cards().judge(1)
				}
				
				while j == 3{
					if Cards.cBP>0 && Cards.mode == .scom{//シャドウジャックのみ
						Cards.cBP -= 1	//--は抹消された...
						let removecard=Cards.ccards.last!.card//消す前に保存
						Cards.ccards.removeLast()
						
						makeUseBPResevation(hide: [removecard], BPLabel: (nil,String(Cards.cBP)))//得点計算のためremoveLastの後
						scounter-=1
						
						j=Cards().judge(1)
						continue
					}else{
						pwin()
						break//一番内側からしか抜けられない！
					}
				}
				scounter+=1
			}
			//最終判定(ループ外)
			j=Cards().judge(1)
			if j==0{
				draw()
			}else if j==1{
				pwin()
			}else if j==2{
				plose()
			}
		}else if Cards.mode == .pvp {
			if scounter==0{ //p2のターンへ移行
				
				scounter+=1
				
				centerLabel.text="P2のターン"
				
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
			
		}else if Cards.mode == .netp1 {
			repeat { //最新まで受信
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			centerLabel.text="相手のターン"
			
			Cards.state = .p2turn
			nets.sendData()
			
			hitButton.isHidden=true
			standButton.isHidden=true
			self.isPaused=false
			
		}else {//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			Cards.state = .judge
			nets.sendData()
			Cards.state = .end	  //今後の受信を停止
			
			//最終判定(ループ外)
			let j=Cards().judge(1)
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
		if Cards.mode == .pvp || Cards.mode == .com || Cards.mode == .scom{
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
		}
		//ボタンを隠す
		resetButton.isHidden=true
		titleButton.isHidden=true
		
		if Cards.mode == .pvp || Cards.mode == .com || Cards.mode == .scom{
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
		if Cards.mode == .pvp || Cards.mode == .com || Cards.mode == .scom{
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
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
