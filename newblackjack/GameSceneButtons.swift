
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
		
		if Cards.mode == .netp2{
			hitButton.isHidden=true
		}else{
			hitButton.isHidden=false
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
						
		if Cards.mode == .netp2{
			standButton.isHidden=true
		}else{
			standButton.isHidden=false
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
		
		resetButton.isHidden=true
		
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
		
		titleButton.isHidden=true

	}

	
}
