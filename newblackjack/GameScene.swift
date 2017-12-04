//
//  GameScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/01.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: Sounds{  //描写などの処理を主に行うクラス。音の再生終了の通知を受け取るためDelegateを実装。(SKSceneはSoundsで継承)
	//Buttons.swift,Labels.swift,Images.swiftでこのクラスを拡張している。
	
	
	var pScrollNode: ScrollNode!
	var cScrollNode: ScrollNode!
	var last:CFTimeInterval!
	let queue = DispatchQueue.main    //メインスレッド
	let nets = net()	//netクラスのインスタンス化
	var didchange = false   //攻守交代(netp2用)
	var comRoop = false	//(com,scom用)
	var showResult = results.wait //centerLabelに結果を表示する
	var cheight: CGFloat!
	var cwidth: CGFloat!
	
	//画像
	var card:[SKSpriteNode] = []	  //カードの画像(空の配列)
	var pBPim = SKSpriteNode()
	var cBPim = SKSpriteNode()
	
	
	//ラベル
	var specialLabels:[specialLabelNames:SKLabelNode]=[:]//特殊カードの攻撃力、体力
	var pBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")//BP
	var cBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	var cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var pbjLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //bj表示用のラベル
	var cbjLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var tPointLabel:[SKLabelNode]=[]//トランプの得点ラベル（52個）(cardnumとのindexのずれに注意)
	var centerLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンや最終結果を表示
	var p1Label = SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,comと表示
	var comLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")


	//ボタンを生成
	var hitButton = UIButton()
	var standButton = UIButton()
	var resetButton = UIButton()
	var titleButton = UIButton()
	

	var hcounter = 0
	var chcounter = 0 //comがヒットした数
	var scounter = 0
	var fccardsc = 2	//p2の手札の数(更新前)
	var fpcardsc = 0	//p1の手札の数(更新前)
	static var audioFinish = true
	var resevation:[(sound:SoundType, x:CGFloat?, y:CGFloat?, card:Int?, hide:[Int], pointLabels:(pp:String?,cp:String?), tPointLabels:[(index:Int,value:String,color:UIColor?)], BPLabels:(pBP:String?,cBP:String?))] = []	//音付き描写の予約（音のみの場合もあり）をタプルの配列で表現
	//tPointLabelの変更は現時点でアリス召喚、退場時のみ
	
	
	
	
	//resevationに代入する関数群
	func makePaintResevation(sound:SoundType,x:CGFloat?,y:CGFloat?,card:Int?){//カード表示と持ち点のみ(トランプ、特殊カードを引いたとき用、持ち点は代入時の値を取得して代入)
		resevation.append((sound,x,y,card,[],Cards().getpoints(),[],(nil,nil)))
	}
	func makeAliceResevation(x:CGFloat?,y:CGFloat?,card:Int?,tPointLabel:[(index:Int,value:String,color:UIColor?)]){//カード表示と得点群のみ(アリス引いたとき用)
		var TPLabel = tPointLabel
		for i in 1...TPLabel.count{
			TPLabel[i-1].color = SKColor.orange
		}
		resevation.append((.aliceIn,x,y,card,[],(nil,nil),[],(nil,nil)))
		resevation.append((.debuffField,nil,nil,nil,[],Cards().getpoints(),TPLabel,(nil,nil)))
	}
	func makeOlivieResevation(x:CGFloat?,y:CGFloat?,card:Int?,BPLabel:(pBP:String?,cBP:String?)){//カード表示と持ち点、BPのみ(オリヴィエ引いたとき用)
		resevation.append((.olivieIn,x,y,card,[],Cards().getpoints(),[],(nil,nil)))
		resevation.append((.BP3,nil,nil,nil,[],(nil,nil),[],BPLabel))
	}
	func makeLuciferCureResevation(){//バスト時に回復する用
		resevation.append((.luciferEffect,nil,nil,nil,[],(nil,nil),[],(nil,nil)))
		resevation.append((.cure,nil,nil,nil,[],Cards().getpoints(),[],(nil,nil)))
	}
	func makeHideAndPaintResevation(sound:SoundType,x:CGFloat?,y:CGFloat?,card:Int?,hide:[Int]){//カード表示と非表示、持ち点のみ(バハムートの効果｛→破壊音8｝、comの２枚目｛→カード音1or特殊カード音3~7｝用)
		
		resevation.append((sound,x,y,card,hide,Cards().getpoints(),[],(nil,nil)))
	}
	func makeUseBPResevation(hide:[Int],BPLabel:(pBP:String?,cBP:String?)){//カード非表示と、持ち点、BPのみ(bust回避用)
		resevation.append((.br,nil,nil,nil,hide,Cards().getpoints(),[],BPLabel))
	}
	
	
	override func didMove(to view: SKView) {//このシーンに移ったときに最初に実行される
		
		
		
		resevation.append((sound: .none, x: nil, y: nil, card: nil, hide: [], pointLabels: (pp: nil, cp: nil), tPointLabels: [], BPLabels: (pBP: nil, cBP: nil)))
		
		Cards.pBP = 2
		Cards.cBP = 3
		
		/*音の設定*/
		setAllSounds()
		
		playcard.delegate = self//デリゲート先（通知先）に自分を設定する。
		summon.delegate = self
		satanIn.delegate = self
		olivieIn.delegate = self
		bahamutIn.delegate = self
		zeusIn.delegate = self
		aliceIn.delegate = self
		luciferIn.delegate = self
		luciferEffect.delegate = self
		breakcard.delegate = self
		BP3Sound.delegate = self
		cureSound.delegate = self
		debuffSound.delegate = self
		
		
		/*描写物の設定*/
		self.cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		self.cwidth = cheight*2/3
		
		//スクロールノード TODO:可変長に
		self.pScrollNode = ScrollNode(size: CGSize(width: cwidth*10, height: cheight) ,position: CGPoint(x:0, y:0) )
		self.cScrollNode = ScrollNode(size: CGSize(width: cwidth*10, height: cheight) ,position: CGPoint(x:0, y:view.frame.height - cheight) )
		pScrollNode.zPosition = 0
		cScrollNode.zPosition = 0
		self.addChild(pScrollNode)
		self.addChild(cScrollNode)
		
		//ラベル
		setLabels(frame_height: view.frame.height, frame_width: view.frame.width)
		
		//背景
		if Cards.mode == .scom{
			backgroundColor = SKColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
		}else{
			backgroundColor = SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		}
		
		
		//画像
		setImages()
		
		if Cards.mode == .com || Cards.mode == .scom || Cards.mode == .pvp{
			//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
			let pccards = Cards().setcard()
			
			//Aの得点の確認
			checkA()
			
			//各トランプの得点の値を設定（初期値設定のためこの位置（setcardより後、アリスより前））
			setTPointLabelsText()
			
			//各手札を表示
			for (index,value) in pccards.pcards.enumerated(){//プレイヤー側
				if value.0 < 53{//トランプ
					//１枚目がアリスであるかの確認
					if Cards.pcards[0].card == 57 || Cards.pcards[0].card == 62 || Cards.pcards[0].card == 63{
						Cards.pcards[1].point += 1
						tPointLabel[value.0-1].fontColor = .orange
						tPointLabel[value.0-1].text = String(Cards.pcards[1].point)
					}
					
					makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
				}else if value.0 == 54 || value.0 == 58 || value.0 == 59{//オリヴィエ
					Cards.pBP = 3
					makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0, BPLabel: (pBP: "3", cBP: nil))
				}else if (value.0 == 57 || value.0 == 62 || value.0 == 63) && index == 1 {//2枚目アリス
					if Cards.pcards[0].card < 53{
						Cards.pcards[0].point += 1
					}
					makeAliceResevation(x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0, tPointLabel: [(Cards.pcards[0].card-1,String(Cards.pcards[0].point),SKColor.orange)])
					
				}else{//その他の特殊カード
					
					let i = getSpecialEnteringSoundType(card: value.0)
					makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
				}
			}
			
			//cpuの1枚目の表示
			if pccards.ccards[0].0 < 53{
				makePaintResevation(sound: .card, x: cwidth/2, y: frame.size.height-cheight/2, card: pccards.ccards[0].0)
			}else if pccards.ccards[0].0 == 54 || pccards.ccards[0].0 == 58 || pccards.ccards[0].0 == 59{//オリヴィエ
				Cards.cBP = 3
				makeOlivieResevation(x: cwidth/2, y: frame.size.height-cheight/2, card: pccards.ccards[0].0, BPLabel: (pBP: nil, cBP: "3"))
			}else{
				let i = getSpecialEnteringSoundType(card: pccards.ccards[0].0)
				makePaintResevation(sound: i, x: cwidth/2, y: frame.size.height-cheight/2, card: pccards.ccards[0].0)
				//アリスの処理は不要
			}
			
			//cpuの2枚目の表示
			makePaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: 0)
			
		}else{//ネット系
			
			//各トランプの得点の値を設定（初期値設定のためこの位置（setcardより後、アリスより前））
			setTPointLabelsText()
			
			let pcards:[(Int,Int)] = Cards.pcards
			let ccards:[(Int,Int)] = Cards.ccards
			
			if Cards.mode == .netp2{
				//1p（敵）の各手札を表示
				for (index,value) in pcards.enumerated(){
					makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(index), y: self.frame.size.height-cheight/2, card: value.0)
				}
				
				//2pの1枚目は表,2枚目は裏向き
				makePaintResevation(sound: .card, x: cwidth/2, y: cheight/2, card: ccards[0].0)
				makePaintResevation(sound: .card, x: cwidth/2+cwidth, y: cheight/2, card: 0)
			}else{//netp1
				
				//各手札を表示
				for (index,value) in pcards.enumerated(){//プレイヤー側
					if value.0 < 53{//トランプ
						makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
						for i in Cards.pcards{//アリスがあるかの確認
							if i.card == 57 || i.card == 62 || i.card == 63{
								Cards.pcards[index].point += 1
								tPointLabel[value.0-1].fontColor = .orange
								tPointLabel[value.0-1].text = String(Cards.pcards[index].point)
							}
						}
					}else if value.0 == 54 || value.0 == 58 || value.0 == 59{//オリヴィエ
						Cards.pBP = 3
						makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0, BPLabel: (pBP: "3", cBP: nil))
					}else{//その他の特殊カード
						
						let i = getSpecialEnteringSoundType(card: value.0)
						makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
					}//アリス側からの得点操作は不要（最初に一気に配るから）
				}
				
				//cpuの1枚目の表示
				if ccards[0].0 < 53{
					makePaintResevation(sound: .card, x: cwidth/2, y: frame.size.height-cheight/2, card: ccards[0].0)
				}else if ccards[0].0 == 54 || ccards[0].0 == 58 || ccards[0].0 == 59{//オリヴィエ
					Cards.cBP=3
					makeOlivieResevation(x: cwidth/2, y: frame.size.height-cheight/2, card: ccards[0].0, BPLabel: (pBP: nil, cBP: "3"))
				}else{
					let i = getSpecialEnteringSoundType(card: ccards[0].0)
					makePaintResevation(sound: i, x: cwidth/2, y: frame.size.height-cheight/2, card: ccards[0].0)
					//アリスの処理は不要
				}
				
				//cpuの2枚目の表示
				makePaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: 0)
			}
			
			//Aの得点の確認→preparingSceneで行う
		}
		
		
		// ボタンを設定.
		setButtons(frame_height: view.frame.height, frame_width: view.frame.width)

		//BJの判定
		let j = Cards().judge(0)
		if j == 5{//両方がbj
			
			showResult = .bothBJ
			
			draw()
			
			//2枚目を表に向ける
			var ccards = Cards.ccards
			if ccards[1].card < 53{
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}else{
				let i = getSpecialEnteringSoundType(card: ccards[1].card)
				
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}
			
			Cards.state = .end
			Cards.pcards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards.removeAll()
			if Cards.mode == .netp1{
				nets.sendData()
			}
			
		}else if j == 3{//pがbj
			if Cards.ccards[0].card == 57 || Cards.ccards[0].card == 62 || Cards.ccards[0].card == 63 {//1枚目アリスの確認
				Cards.ccards[1].point += 1
				tPointLabel[Cards.ccards[1].card-1].fontColor = SKColor.orange
				tPointLabel[Cards.ccards[1].card-1].text = String(Cards.ccards[1].point)
			}
			
			//2枚目を表に向ける
			var ccards = Cards.ccards
			if ccards[1].card < 53{
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}else if Cards.ccards[1].card == 57 || Cards.ccards[1].card == 62 || Cards.ccards[1].card == 63{//2枚目アリスの確認
				Cards.ccards[0].point += 1
				
				let y = (Cards.mode == .netp2 ? cheight/2 : frame.size.height-cheight/2)
				
				resevation.append((sound:.none,x:nil,y:nil,card:nil,hide:[0],pointLabels:(pp:nil,cp:nil),tPointLabels:[],BPLabels:(pBP:nil,cBP:nil)))
				makeAliceResevation(x: cwidth/2+cwidth, y: y, card: ccards[1].card, tPointLabel: [(Cards.ccards[0].card-1,String(Cards.ccards[0].point),SKColor.orange)])
			}else{//2枚目が他の特殊カード
				let i = getSpecialEnteringSoundType(card: ccards[1].card)
				
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}
			
			
			Cards.state = .end
			Cards.pcards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards.removeAll()
			if Cards.mode == .netp1{
				nets.sendData()
			}
			
			showResult = .pBJ
			pwin()
		}else if j == 4{
			//2枚目を表に向ける
			var ccards = Cards.ccards
			if ccards[1].card < 53{
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}else{
				let i = getSpecialEnteringSoundType(card: ccards[1].card)

				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}
			
			Cards.state = .end
			Cards.pcards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards.removeAll()
			if Cards.mode == .netp1{
				nets.sendData()
			}
			
			showResult = .cBJ
			plose()
		}
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		
		self.pScrollNode.update(currentTime: currentTime)
		self.cScrollNode.update(currentTime: currentTime)
		
		let cheight = (view?.frame.height)!/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		//トランプ得点ラベルの位置更新:TODO
		for i in 1...52{
			tPointLabel[i-1].position = CGPoint(x:card[i].position.x+cwidth/2-cheight*16/138,y:card[i].position.y+cheight/2-cheight*28/138)
		}
//		//トランプ得点ラベルの得点更新
//		for i in Cards.pcards{
//			if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
//				tPointLabel[i.card-1].text=String(i.point)
//
//				//得点が増えてるものをオレンジ色にする
//				if (i.card-1)%13 > 8 && i.point>10{//10,J,Q,K
//					tPointLabel[i.card-1].fontColor=SKColor.orange
//				}else if (i.card-1)%13 <= 8 && i.point>i.card%13{
//					tPointLabel[i.card-1].fontColor=SKColor.orange
//				}else{
//					tPointLabel[i.card-1].fontColor=SKColor.white
//				}
//			}
//		}
//		for i in Cards.ccards{
//			if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
//				tPointLabel[i.card-1].text=String(i.point)
//
//				//得点が増えてるものをオレンジ色にする
//				if (i.card-1)%13 > 8 && i.point>10{//10,J,Q,K
//					tPointLabel[i.card-1].fontColor=SKColor.orange
//				}else if (i.card-1)%13 <= 8 && i.point>i.card%13{
//					tPointLabel[i.card-1].fontColor=SKColor.orange
//				}else{
//					tPointLabel[i.card-1].fontColor=SKColor.white
//				}
//			}
//		}
		
		//ラベルとカードをくっつける:TODO
		updateSpecialLabelsPosition()
		
		//音の処理
		if GameScene.audioFinish == true {
			if resevation.count>0{
				resetButton.isEnabled=false
				titleButton.isEnabled=false
				hitButton.isEnabled=false
				standButton.isEnabled=false
				
				//カードを隠す処理（バハのため、先に隠してから表示）
				for i in resevation[0].hide{
					
					card[i].position = CGPoint(x:0,y:10000)    //枠外に
					if i<53 && i>0{//トランプ表の得点も隠す
						tPointLabel[i-1].position=CGPoint(x:0,y:10000)
					}
				}
				
				//カードの表示、移動
				if let cardnum = resevation[0].card{
					if resevation[0].y! > (view?.frame.height)!/2{
						//カード
						self.cScrollNode.contentNode.addChild(card[cardnum])
						//得点ラベル
						if cardnum > 52{
							specialLabelsAddChildren(cardNum: cardnum, player: .com)
						}else if cardnum > 0{
							self.cScrollNode.contentNode.addChild(tPointLabel[cardnum - 1])
						}
					}else{
						self.pScrollNode.contentNode.addChild(card[cardnum])
						if cardnum > 52{
							specialLabelsAddChildren(cardNum: cardnum, player: .p1)
						}else if cardnum > 0{
							self.pScrollNode.contentNode.addChild(tPointLabel[cardnum - 1])
						}
					}
					
					card[cardnum].position = CGPoint(x:resevation[0].x!, y:cheight/2)
				}
				
				//音を鳴らす
				switch(resevation[0].sound){
				case .card : playcard.currentTime=0
				playcard.play()
				GameScene.audioFinish=false
				case .cardAndSummon : summon.currentTime=0
				summon.play()
				GameScene.audioFinish=false
				case .satanIn : satanIn.currentTime=0
				satanIn.play()
				GameScene.audioFinish=false
				case .olivieIn : olivieIn.currentTime=0
				olivieIn.play()
				GameScene.audioFinish=false
				case .bahamutIn : bahamutIn.currentTime=0
				bahamutIn.play()
				GameScene.audioFinish=false
				case .zeusIn : zeusIn.currentTime=0
				zeusIn.play()
				GameScene.audioFinish=false
				case .aliceIn : aliceIn.currentTime=0
				aliceIn.play()
				GameScene.audioFinish=false
				case .luciferIn : luciferIn.currentTime=0
				luciferIn.play()
				GameScene.audioFinish=false
				case .luciferEffect : luciferEffect.currentTime=0
				luciferEffect.play()
				GameScene.audioFinish=false
				case .br: breakcard.currentTime=0
				breakcard.play()
				GameScene.audioFinish=false
				case .BP3 : BP3Sound.currentTime=0
				BP3Sound.play()
				GameScene.audioFinish=false
				case .cure : cureSound.currentTime=0
				cureSound.play()
				GameScene.audioFinish=false
				case .debuffField : debuffSound.currentTime=0
				debuffSound.play()
				GameScene.audioFinish=false
					
				default : print("該当の音が作られていません:\(resevation[0].sound)")
					break
				}
				
				//ppLabel,cpLabelの更新（String?,String?）
				if let pp = resevation[0].pointLabels.pp{
					ppLabel.text = pp
				}
				if let cp = resevation[0].pointLabels.cp{
					cpLabel.text = cp
				}
				
				
				//tPointLabelの更新[(どれ,String,UIColor)]（アリスを３枚め以降引いたときのみ）
				for i in resevation[0].tPointLabels{//（今は重複するので不要だが,Aのタイミングも合わせるときに使う？）
					if i.index < 52{//トランプ
						tPointLabel[i.index].text = i.value
						tPointLabel[i.index].fontColor = i.color	//(注)fontColor!=color
					}
				}
				
				//pBP,cBPLabelの更新(String,String)
				if let pBP=resevation[0].BPLabels.pBP{
					pBPLabel.text="×"+pBP
				}
				if let cBP=resevation[0].BPLabels.cBP{
					cBPLabel.text="×"+cBP
				}
				
				resevation.removeFirst()
				
			}else{
				//最終結果の表示
				if showResult == .pWin || showResult == .pBJ{
					if Cards.mode == .pvp{
						centerLabel.text = "P1 Win!"
					}else if Cards.mode == .netp2{
						centerLabel.text = "You Lose..."
					}else {
						centerLabel.text = "You Win!"
					}
					
					if showResult == .pBJ {
						pbjLabel.isHidden = false
						ppLabel.isHidden = false
						cpLabel.isHidden = false
					}
					
					showResult = .wait
				}else if showResult == .pLose || showResult == .cBJ{
					if Cards.mode == .pvp{
						centerLabel.text = "P2 Win!"
					}else if Cards.mode == .netp2{
						centerLabel.text = "You Win!"
					}else {
						centerLabel.text = "You Lose..."
					}
					
					if showResult == .cBJ {
						cbjLabel.isHidden = false
						ppLabel.isHidden = false
						cpLabel.isHidden = false
					}
					
					showResult = .wait
				}else if showResult == .draw || showResult == .bothBJ{
					centerLabel.text = "Draw"
					
					if showResult == .bothBJ {
						pbjLabel.isHidden = false
						cbjLabel.isHidden = false
						ppLabel.isHidden = false
						cpLabel.isHidden = false
					}
					
					showResult = .wait
				}
			}
		}
		
		
		
		//通信の処理
		if Cards.mode == .netp1 || Cards.mode == .netp2{
			if last == nil{
				last = currentTime
			}
			
			// 3秒おきに行う処理をかく。
			if last + 1 <= currentTime {
				queue.async {
					
					//				if self.sentfirst==true{    //初期手札を送る前の空データの受信防止
					//サーバーから山札、手札を獲得（1つずつ）
					if Cards.state != .end{
						self.nets.receiveData()
					}
					
					if Cards.state == .br{	  //breakを受信したら強制終了
						self.hitButton.isHidden=true
						self.standButton.isHidden=true
						self.resetButton.isHidden=true
						self.titleButton.isHidden=true
						
						let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
						let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
						gameScene.scaleMode = SKSceneScaleMode.fill
						self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
					}
					
					self.hitButton.isEnabled=true
					self.standButton.isEnabled=true
					self.resetButton.isEnabled=true
					self.titleButton.isEnabled=true
					
					if Cards.mode == .netp1{
						let ccardsc=Cards.ccards.count
						
						if Cards.state == .judge{
							
							//最終判定(ループ外)
							let j=Cards().judge(1)
							if j==0{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.draw()
							}else if j==1{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.pwin()
							}else if j==2{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.plose()
							}
						}
						
						
						
						if ccardsc != self.fccardsc && (Cards.state == .p2turn||Cards.state == .judge){//更新を受信したとき
							self.playcard.currentTime = 0
							self.playcard.play()
							
							let ccards:[(Int,Int)] = Cards.ccards
							
							//2p（敵）の引いた手札を表示
							self.makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(ccardsc-1), y: self.frame.size.height-cheight/2, card: ccards[ccardsc-1].0)
							
							//敵の得点表示
							self.cpLabel.isHidden = false
							
							self.fccardsc = ccardsc
							//引いた直後にバストの判定(ループ内)
							let j = Cards().judge(1)
							if j == 3{
								
								//ルシフェル探し(todo)
								for i in Cards.ccards{
									
								}
								
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								
								self.pwin()
							}
							
						}
					}else if Cards.mode == .netp2{
						let pcardsc = Cards.pcards.count    //毎回更新
						if (pcardsc > self.fpcardsc) && (Cards.state == .p1turn||Cards.state == .p2turn){//更新されたら(startはまだ配った手札が来てない状態、end,breakは手札がからの状態、judgeでもエラー発生)
							
							let pcards:[(Int,Int)] = Cards.pcards
							
							//敵が引いたカードを表示
							self.makePaintResevation(sound: .card, x: cwidth/2+cwidth*CGFloat(pcardsc-1), y: self.frame.size.height-cheight/2, card: pcards[pcardsc-1].0)
							
							
							//敵の得点表示????????
							self.ppLabel.isHidden=false
							
							self.fpcardsc = pcardsc
							
							//敵のbustの判定
							let j = Cards().judge(1)
							if j == 4{
								self.isPaused = true  //updateによる受信防止
								self.plose()
								
								//2枚目を表に向ける
								var ccards = Cards.ccards
								self.makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
								
								self.isPaused = false
								
								//配列から消す前に各トランプの得点を表示
								for i in Cards.pcards{
									if i.card < 53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
										self.tPointLabel[i.card-1].position = CGPoint(x:self.card[i.card].position.x+cwidth/2-cheight*16/138,y:self.card[i.card].position.y+cheight/2-cheight*28/138)
										self.tPointLabel[i.card-1].text = String(i.point)
									}
								}
								for i in Cards.ccards{
									if i.card < 53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
										self.tPointLabel[i.card-1].position = CGPoint(x:self.card[i.card].position.x+cwidth/2-cheight*16/138,y:self.card[i.card].position.y+cheight/2-cheight*28/138)
										self.tPointLabel[i.card-1].text = String(i.point)
									}
								}
								
								//snetp2用（以下は未完成）
								self.specialLabels[.satanA]!.position = CGPoint(x:self.card[53].position.x-cwidth/2+cheight*11/138,y:self.card[53].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.satanHP]!.position = CGPoint(x:self.card[53].position.x+cwidth/2-cheight*11/138,y:self.card[53].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.olivieA]!.position = CGPoint(x:self.card[54].position.x-cwidth/2+cheight*11/138,y:self.card[54].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.olivieHP]!.position = CGPoint(x:self.card[54].position.x+cwidth/2-cheight*11/138,y:self.card[54].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.bahamutA]!.position = CGPoint(x:self.card[55].position.x-cwidth/2+cheight*11/138,y:self.card[55].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.bahamutHP]!.position = CGPoint(x:self.card[55].position.x+cwidth/2-cheight*11/138,y:self.card[55].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.zeusA]!.position = CGPoint(x:self.card[56].position.x-cwidth/2+cheight*11/138,y:self.card[56].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.zeusHP]!.position = CGPoint(x:self.card[56].position.x+cwidth/2-cheight*11/138,y:self.card[56].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.aliceA]!.position = CGPoint(x:self.card[57].position.x-cwidth/2+cheight*11/138,y:self.card[57].position.y-cheight/2+cheight*8/138)
								self.specialLabels[.aliceHP]!.position = CGPoint(x:self.card[57].position.x+cwidth/2-cheight*11/138,y:self.card[57].position.y-cheight/2+cheight*8/138)
								
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
							}
						}
						if Cards.state == .p2turn && !self.didchange{//こちらにターンが回ってきたとき
							
							self.hitButton.isHidden = false
							self.standButton.isHidden = false
							
							//2枚目を表に向ける
							var ccards = Cards.ccards
							self.makeHideAndPaintResevation(sound: .card, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
							
							//得点を表示する
							self.cpLabel.isHidden = false
							self.centerLabel.text = "あなたのターン"
							
							self.didchange = true
						}
					}
					self.last = currentTime
				}
			}//if last + 1 <= currentTime
		}
	}

//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		let location = touches.first?.location(in: self)
//		print("cheight:\(cheight)")
//		print("frame.height - cheight:\(view!.frame.height - cheight)")
//
//
//
//
//		if location!.y < cheight{
//
//			self.pScrollNode.touchesBeganIn(touches, with: event)
//		}else if location!.y > view!.frame.height - cheight{
//
//			self.cScrollNode.touchesBeganIn(touches, with: event)
//		}
//	}
	
	
	
	func pwin(){
		
		hitButton.isHidden = true
		standButton.isHidden = true
		
		if showResult == .wait {
			showResult = .pWin
		}
		
		endofthegame()
	}
	
	func plose(){
		hitButton.isHidden = true
		standButton.isHidden = true
		
		if showResult == .wait {
			showResult = .pLose
		}
		
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		hitButton.isHidden = true
		standButton.isHidden = true
		
		if showResult == .wait {
			showResult = .draw
		}
		
		endofthegame()
	}
	
	func endofthegame(){
		// リセット、タイトルボタンを表示.
		resetButton.isHidden = false
		titleButton.isHidden = false
	}
	
	func getSpecialEnteringSoundType(card:Int) -> SoundType{
		
		guard card > 52 else {
			print("特殊カードではありません")
			return .none
		}
		
		switch card {
		case 53:
			return .satanIn
		case 54,58,59:
			return .olivieIn
		case 55,60,61:
			return .bahamutIn
		case 56:
			return .zeusIn
		case 57,62,63:
			return .aliceIn
		case 64,65,66:
			return .luciferIn
		default:
			print("未定義の特殊カードです")
			return .none
		}
	}
	
	func checkA(){
		//Aの得点の確認
		let (ppoint,cpoint,_,_) = Cards().calculatepoints()
		for (index,value) in Cards.pcards.enumerated(){
			if value.card<53{//トランプ限定
				if value.card%13 == 1 && ppoint.inA<22{
					Cards.pcards[index].point+=10
					tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
					tPointLabel[value.card-1].fontColor = .orange
					break	  //二枚目以降は更新しない
				}
				if value.card%13==1 && value.point>9{
					if ppoint.noA>21{
						Cards.pcards[index].point -= 10
						tPointLabel[value.card-1].text = String(Cards.pcards[index].point)
						tPointLabel[value.card-1].fontColor = .white
						break //後に直すべきAはないはず
					}
				}
			}
		}
		for (index,value) in Cards.ccards.enumerated(){
			if value.card<53{//トランプ限定
				if value.point == 1 && cpoint.inA<22{
					Cards.ccards[index].point += 10
					tPointLabel[value.card-1].text = String(Cards.pcards[index].point)
					tPointLabel[value.card-1].fontColor = .orange
					break	  //二枚目以降は更新しない
				}
				if value.card%13 == 1 && value.point > 9 && cpoint.noA > 21{
					Cards.ccards[index].point -= 10
					tPointLabel[value.card-1].text = String(Cards.pcards[index].point)
					tPointLabel[value.card-1].fontColor = .white
					break //後に直すべきAはないはず
				}
			}
		}
	}
	
	func checkLucifer(player:Player){
		switch player {
		case .p1:
			for (index,i) in Cards.pcards.enumerated(){
				if i.card == 64 || i.card == 65 || i.card == 66 {
					Cards.pcards[index].point -= 4	//とりあえずルシフェル自体の得点を下げる
					makeLuciferCureResevation()
				}
			}
		case .com:
			for (index,i) in Cards.ccards.enumerated(){
				if i.card == 64 || i.card == 65 || i.card == 66 {
					Cards.ccards[index].point -= 4	//とりあえずルシフェル自体の得点を下げる
					makeLuciferCureResevation()
				}
			}
		}
	}
	
	//再生終了時の呼び出しメソッド
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {//playしたクラスと同じクラスに入れる必要あり？
		GameScene.audioFinish = true
		
		if resevation.count == 0{
			resetButton.isEnabled = true
			titleButton.isEnabled = true
			hitButton.isEnabled = true
			standButton.isEnabled = true
		}
	}
	// デコード中にエラーが起きた時に呼ばれるメソッド
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
		print(error as Any)
	}
}

enum results{//centerLabelへの受け渡し用
	case pWin,pLose,draw,wait,pBJ,cBJ,bothBJ
}
enum specialLabelNames{
	case satanA,satanHP,olivieA,olivieHP,bahamutA,bahamutHP,zeusA,zeusHP,aliceA,aliceHP,olivieA2,olivieHP2,bahamutA2,bahamutHP2
	,aliceA2,aliceHP2,olivieA3,olivieHP3,bahamutA3,bahamutHP3,aliceA3,aliceHP3,luciferA,luciferHP,luciferA2,luciferHP2,luciferA3,luciferHP3
}

/*
soundは
0:無音、1:カード音、(2:カード召喚音)、3:サタンin、4:オリヴィエin,5:バハムートin,6:ゼウスin,7:アリスin,8:破壊音,9:ルシフェルin,10:ルシフェル回復
だった
*/
enum SoundType{
	case satanIn,olivieIn,bahamutIn,zeusIn,aliceIn,luciferIn,luciferEffect,card,cardAndSummon,br,cure,debuffField,BP3,none
}

enum Player{
	case p1,com
}
