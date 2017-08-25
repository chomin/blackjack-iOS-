
//
//  Buttons.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/25.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit

class Buttons{
	func setButtons(frame_height: CGFloat, frame_width: CGFloat){
		
		let cheight = frame_height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		
		GameScene.hitButton.frame = CGRect(x: 0,y: 0,width: cheight*200/138,height: cheight*40/138)
		GameScene.hitButton.backgroundColor = UIColor.red
		GameScene.hitButton.layer.masksToBounds = true
		GameScene.hitButton.setTitle("ヒット", for: UIControlState())
		GameScene.hitButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.hitButton.setTitle("ヒット", for: UIControlState.highlighted)
		GameScene.hitButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.hitButton.setTitle("...", for: UIControlState.disabled)
		GameScene.hitButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.hitButton.layer.cornerRadius = 20.0
		GameScene.hitButton.layer.position = CGPoint(x: frame_width-cheight*100/138, y:frame_height/2-cheight*40/138)
		
		if Cards.mode == .netp2{
			GameScene.hitButton.isHidden=true
		}else{
			GameScene.hitButton.isHidden=false
		}
		
		
		GameScene.standButton.frame = CGRect(x: 0,y: 0,width: cheight*200/138,height: cheight*40/138)
		GameScene.standButton.backgroundColor = UIColor.red;
		GameScene.standButton.layer.masksToBounds = true
		GameScene.standButton.setTitle("スタンド", for: UIControlState())
		GameScene.standButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.standButton.setTitle("スタンド", for: UIControlState.highlighted)
		GameScene.standButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.standButton.setTitle("...", for: UIControlState.disabled)
		GameScene.standButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.standButton.layer.cornerRadius = 20.0
		GameScene.standButton.layer.position = CGPoint(x: frame_width-cheight*100/138, y:frame_height/2+cheight*40/138)
						
		if Cards.mode == .netp2{
			GameScene.standButton.isHidden=true
		}else{
			GameScene.standButton.isHidden=false
		}
		
		GameScene.resetButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		GameScene.resetButton.backgroundColor = UIColor.red;
		GameScene.resetButton.layer.masksToBounds = true
		GameScene.resetButton.setTitle("リプレイ", for: UIControlState())
		GameScene.resetButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.resetButton.setTitle("リプレイ", for: UIControlState.highlighted)
		GameScene.resetButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.resetButton.setTitle("...", for: UIControlState.disabled)
		GameScene.resetButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.resetButton.layer.cornerRadius = 20.0
		GameScene.resetButton.layer.position = CGPoint(x: frame_width-100, y:frame_height-20)
		
		GameScene.resetButton.isHidden=true
		
		GameScene.titleButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		GameScene.titleButton.backgroundColor = UIColor.red;
		GameScene.titleButton.layer.masksToBounds = true
		GameScene.titleButton.setTitle("タイトルへ戻る", for: UIControlState())
		GameScene.titleButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.titleButton.setTitle("タイトルへ戻る", for: UIControlState.highlighted)
		GameScene.titleButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.titleButton.setTitle("...", for: UIControlState.disabled)
		GameScene.titleButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.titleButton.layer.cornerRadius = 20.0
		GameScene.titleButton.layer.position = CGPoint(x: frame_width-100, y:frame_height-70)
		
		GameScene.titleButton.isHidden=true

	}

}
