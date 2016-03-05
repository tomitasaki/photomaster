//
//  ViewController.swift
//  photomaster
//
//  Created by hmlab book pro on 2016/02/23.
//  Copyright © 2016年 hmlab book pro. All rights reserved.
//

import UIKit
import Social


class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    //写真表示用imageview
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func precentPickerController(sourceType: UIImagePickerControllerSourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let picker = UIImagePickerController()
            //ソースタイプ設定
            picker.sourceType = sourceType
            //デリゲート設定
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //画像出力
        photoImageView.image = image
    }
    //画像取得ボタンあとに呼ばれる
    @IBAction func selectButtonTapped(sender: UIButton){
        let alertController = UIAlertController(title: "画像の取得先を選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title:"カメラ" ,style: .Default){
            action in
            self.precentPickerController(.Camera)
        }
        let secondAction = UIAlertAction(title:"アルバム" ,style: .Default){
            action in
            self.precentPickerController(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction(title:"キャンセル" ,style: .Cancel, handler:nil)
        
        //設定した選択肢をアラートに登録
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        //アラート表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //テキスト合成メソッド
    func drawText(image: UIImage)->UIImage{
        let text = "LifeisTech!\nXmasCamp2015"
        //グラフィックスコンテキスト生成、編集を開始
        UIGraphicsBeginImageContext(image.size)
        //読み込んだ写真を書き出す
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        let textRect = CGRectMake(5, 5, image.size.width - 5, image.size.height - 5)
        
        let textFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(120),
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle()
        ]
        text.drawInRect(textRect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    //マスク画像を合成
    func drawMaskInage(image: UIImage) ->UIImage{
        UIGraphicsBeginImageContext(image.size)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let maskImage = UIImage(named: "tanuki")
        
        let offset: CGFloat = 50.0
        let maskRect = CGRectMake(
            image.size.width - maskImage!.size.width - offset,
            image.size.height - maskImage!.size.height - offset,
            maskImage!.size.width,
            maskImage!.size.height
        )
        maskImage!.drawInRect(maskRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        
        return newImage
    }
    //任意のメッセージとOKボタンをもつアラート
    func simpleAlert(titleString: String){
        
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController,animated:true, completion: nil)
    }
    
    //合成ボタンのあと
    @IBAction func processButtonTapped(sender: UIButton){
        guard let selectedPhoto = photoImageView.image else {
            simpleAlert("画像がありません")
            return
        }
        let alertController = UIAlertController(title: "合成するパーツを選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "テキスト", style: .Default){
            action in
            
            //selectedPhotoにテキストを合成して画面に書き出す
            self.photoImageView.image = self.drawText(selectedPhoto)
        }
        let secondAction = UIAlertAction(title: "たぬき", style: .Default){
            action in
            //selectedPhotoに画像を合成して画面に書き出す
            self.photoImageView.image = self.drawMaskInage(selectedPhoto)
        }
        let cencelAction = UIAlertAction(title: "キャンセル", style: .Default, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cencelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    //SNSに投稿　FBorTWのソースタイプ　引数
    func postToSNS(serviceType: String){
        let myComposeView = SLComposeViewController(forServiceType: serviceType)
        myComposeView.setInitialText("PhotoMasterからの投稿✨")
        myComposeView.addImage(photoImageView.image)
        self.presentViewController(myComposeView, animated: true, completion: nil)
    }
    //アップロードのあと
    @IBAction func uploadButtonTapped(sender: UIButton){
        
        guard let selectedPhoto = photoImageView.image else{
            simpleAlert("画像がありません")
            return
        }
        let alertController = UIAlertController(title: "アップロード先を選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "フェイスブックに投稿", style: .Default){
            action in
            self.postToSNS(SLServiceTypeFacebook)
        }
        let secondAction = UIAlertAction(title: "ツイッターに投稿", style: .Default){
            action in
            self.postToSNS(SLServiceTypeTwitter)
            
        }
        let thirdAction = UIAlertAction(title: "カメラロールに保存", style: .Default){
            action in
            UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, nil, nil)
            self.simpleAlert("アルバムに保存されました")
        }
        let cencelAction = UIAlertAction(title: "キャンセル", style: .Default, handler: nil)
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(thirdAction)
        alertController.addAction(cencelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

