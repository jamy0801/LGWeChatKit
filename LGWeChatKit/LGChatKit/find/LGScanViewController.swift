//
//  LGScanViewController.swift
//  LGScanViewController
//
//  Created by jamy on 15/9/22.
//  Copyright © 2015年 jamy. All rights reserved.
//

import UIKit
import AVFoundation


class LGScanViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate{

    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let screenSize = UIScreen.mainScreen().bounds.size
    
    var traceNumber = 0
    var upORdown = false
    var timer:NSTimer!
    
    var device : AVCaptureDevice!
    var input  : AVCaptureDeviceInput!
    var output : AVCaptureMetadataOutput!
    var session: AVCaptureSession!
    var preView: AVCaptureVideoPreviewLayer!
    var line   : UIImageView!
    
    // MARK: - init functions
    
    init() {
        super.init(nibName: nil, bundle: nil)
       hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "二维码扫描"
        
        if !setupCamera() {
            return
        }
        
        setupScanLine()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
        timer = NSTimer(timeInterval: 0.02, target: self, selector: "scanLineAnimation", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    override func viewWillDisappear(animated: Bool) {
        traceNumber = 0
        upORdown = false
        session.stopRunning()
        timer.invalidate()
        timer = nil
        
        super.viewWillDisappear(animated)
    }
    
    func setupCamera() -> Bool {
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
          input = try AVCaptureDeviceInput(device: device)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
        
        output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        output.rectOfInterest = makeScanReaderInterestRect()
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        if session.canAddInput(input)
        {
            session.addInput(input)
        }
        if session.canAddOutput(output)
        {
            session.addOutput(output)
        }
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        
        preView = AVCaptureVideoPreviewLayer(session: session)
        preView.videoGravity = AVLayerVideoGravityResizeAspectFill
        preView.frame = self.view.bounds
        
        let shadowView = makeScanCameraShadowView(makeScanReaderRect())
        self.view.layer.insertSublayer(preView, atIndex: 0)
        self.view.addSubview(shadowView)
        
        return true
    }
    
    func setupScanLine() {
        let rect = makeScanReaderRect()
        
        var imageSize: CGFloat = 20.0
        let imageX = rect.origin.x
        let imageY = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height + 2
        
        /// 四个边角
        let imageViewTL = UIImageView(frame: CGRectMake(imageX, imageY, imageSize, imageSize))
        imageViewTL.image = UIImage(named: "scan_tl")
        imageSize = (imageViewTL.image?.size.width)!
        self.view.addSubview(imageViewTL)
        
        let imageViewTR = UIImageView(frame: CGRectMake(imageX + width - imageSize, imageY, imageSize, imageSize))
        imageViewTR.image = UIImage(named: "scan_tr")
        self.view.addSubview(imageViewTR)
        
        let imageViewBL = UIImageView(frame: CGRectMake(imageX, imageY + height - imageSize, imageSize, imageSize))
        imageViewBL.image = UIImage(named: "scan_bl")
        self.view.addSubview(imageViewBL)
        
        let imageViewBR = UIImageView(frame: CGRectMake(imageX + width - imageSize, imageY + height - imageSize, imageSize, imageSize))
        imageViewBR.image = UIImage(named: "scan_br")
        self.view.addSubview(imageViewBR)
        
        line = UIImageView(frame: CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 2))
        line.image = UIImage(named: "scan_line")
        self.view.addSubview(line)
    }
    
    // MARK: Rect
    func makeScanReaderRect() -> CGRect {
        let scanSize = (min(screenWidth, screenHeight) * 3) / 5
        var scanRect = CGRectMake(0, 0, scanSize, scanSize)
        
        scanRect.origin.x += (screenWidth / 2) - (scanRect.size.width / 2)
        scanRect.origin.y += (screenHeight / 2) - (scanRect.size.height / 2)
        
        return scanRect
    }
    
    func makeScanReaderInterestRect() -> CGRect {
        let rect = makeScanReaderRect()
        let x = rect.origin.x / screenWidth
        let y = rect.origin.y / screenHeight
        let width = rect.size.width / screenWidth
        let height = rect.size.height / screenHeight
        
        return CGRectMake(x, y, width, height)
    }
    
    func makeScanCameraShadowView(innerRect: CGRect) -> UIView {
        let referenceImage = UIImageView(frame: self.view.bounds)
        
        UIGraphicsBeginImageContext(referenceImage.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
        var drawRect = CGRectMake(0, 0, screenWidth, screenHeight)
        CGContextFillRect(context, drawRect)
        drawRect = CGRectMake(innerRect.origin.x - referenceImage.frame.origin.x, innerRect.origin.y - referenceImage.frame.origin.y, innerRect.size.width, innerRect.size.height)
        CGContextClearRect(context, drawRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        referenceImage.image = image
        
        return referenceImage
    }
    
    // MARK: 定时器
    
    func scanLineAnimation() {
        let rect = makeScanReaderRect()
        
        let lineFrameX = rect.origin.x
        let lineFrameY = rect.origin.y
        let downHeight = rect.size.height
        
        if upORdown == false {
            traceNumber++
            line.frame = CGRectMake(lineFrameX, lineFrameY + CGFloat(2 * traceNumber), downHeight, 2)
            if CGFloat(2 * traceNumber) > downHeight - 2 {
                upORdown = true
            }
        }
        else
        {
            traceNumber--
            line.frame = CGRectMake(lineFrameX, lineFrameY + CGFloat(2 * traceNumber), downHeight, 2)
            if traceNumber == 0 {
                upORdown = false
            }
        }
    }
    
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 {
            return
        }
        
        let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let value = metadata.stringValue
        
        showScanCode(value)
    }
    
    // MARK: show result
    
    func showScanCode(code: String) {
        print("\(code)")
    }
    
}



