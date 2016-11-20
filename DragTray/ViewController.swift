//
//  ViewController.swift
//  DragTray
//
//  Created by Bill Luoma on 11/2/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import UIKit

//MARK: - dlog
func dlog(_ message: String, _ filePath: String = #file, _ functionName: String = #function, _ lineNum: Int = #line)
{
    #if DEBUG
        
        let url  = URL(fileURLWithPath: filePath)
        let path = url.lastPathComponent
        var fileName = "Unknown"
        if let name = path.characters.split(separator: ",").map(String.init).first {
            fileName = name
        }
        let logString = String(format: "%@.%@[%d]: %@", fileName, functionName, lineNum, message)
        NSLog(logString)
        
    #endif
    
}



class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    @IBOutlet var trayArrowImageView: UIImageView!
    
    var newlyCreatedFaceImageView: UIImageView!
    var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var faceStartPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var faceStartTransform: CGAffineTransform = CGAffineTransform.identity
    var faceStartRotationTransform: CGAffineTransform = CGAffineTransform.identity
    var arrowStartRotationTransform: CGAffineTransform = CGAffineTransform.identity
    var trayCenterWhenOpen = CGPoint(x: 187.5, y: 570.0)
    var trayCenterWhenClosed = CGPoint(x: 187.5, y: 728.0)
    var isTrayOpen: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.trayView.center = self.trayCenterWhenClosed
        self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
        self.view.layoutIfNeeded()
        self.isTrayOpen = false
        startPoint = self.trayView.center
        dlog("startPoint trayView.center: \(self.trayView.center)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - Actions
    
    func arrowRotationForTrayPan(translation: CGPoint, velocity: CGPoint) -> CGFloat {
        
        let angleWhenOpen: CGFloat = 0.0
        let angleWhenClosed: CGFloat = .pi
        var rotation: CGFloat  = 0.0
        let isPanningUp = velocity.y < 0
        
        if isPanningUp {
            
            let newCenterY = startPoint.y - fabs(translation.y)
            if newCenterY <= trayCenterWhenOpen.y {
                rotation = angleWhenOpen
            }
            else {
                let multiplier = 1.0 - (fabs(translation.y) / (trayCenterWhenClosed.y - trayCenterWhenOpen.y))
                //dlog("mul: \(multiplier)")
                rotation = angleWhenClosed * multiplier
            }
        }
        else {
            
            let newCenterY = startPoint.y + fabs(translation.y)
            if newCenterY >= trayCenterWhenClosed.y {
                rotation = angleWhenClosed
            }
            else {
                let multiplier = 1.0 - (fabs(translation.y) / (trayCenterWhenClosed.y - trayCenterWhenOpen.y))
                //dlog("mul: \(multiplier)")
                rotation = angleWhenClosed - (angleWhenClosed * multiplier)
            }
        }

        return rotation
    }
    
    @IBAction func onTrayPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let locationInView = panGestureRecognizer.location(in: self.view)
        let velocity = panGestureRecognizer.velocity(in: self.view)
        let translation = panGestureRecognizer.translation(in: self.view)
        let isPanningUp = velocity.y < 0
        
        
        if panGestureRecognizer.state == .began {
            dlog("Gesture began at: \(locationInView)")
            startPoint = self.trayView.center
            arrowStartRotationTransform = trayArrowImageView.transform
        }
        else if panGestureRecognizer.state == .changed {
            
            if isPanningUp {
                
                let newCenterY = startPoint.y + translation.y
                if newCenterY > trayCenterWhenOpen.y {
                    self.trayView.center.y = newCenterY
                }
                dlog("Gesture changed up: \(translation.y), newCenterY: \(newCenterY)")
                let rotation = arrowRotationForTrayPan(translation: translation, velocity: velocity)
                self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: rotation)
                
            }
            else {
                let newCenterY = startPoint.y + translation.y
                
                if newCenterY < trayCenterWhenClosed.y {
                    self.trayView.center.y = newCenterY
                }
                let rotation = arrowRotationForTrayPan(translation: translation, velocity: velocity)
                self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: rotation)

                dlog("Gesture changed down: \(translation.y), newCenterY: \(newCenterY)")
            }
            
        }
        else if panGestureRecognizer.state == .ended {
            dlog("Gesture ended at: \(locationInView), center: \(trayView.center)")
            if isPanningUp {
                openMenu()
            }
            else {
                closeMenu()
            }
        }

    }
    
    func closeMenu() {
        if !isTrayOpen {
            return
        }
        let options: UIViewAnimationOptions = .curveEaseOut
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:0.2, initialSpringVelocity:0.0, options: options,
            animations: { () -> Void in
                self.trayView.center = self.trayCenterWhenClosed
                self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
                self.view.layoutIfNeeded()
            },
            completion: { (done: Bool) -> Void in
                self.isTrayOpen = false
                dlog("trayView.center: \(self.trayView.center)")
        })
    }
    
    func openMenu() {
        if isTrayOpen {
            return
        }
        let options: UIViewAnimationOptions = .curveEaseInOut
        
        UIView.animate(withDuration: 0.3, delay: 0, options: options,
            animations: { () -> Void in
                self.trayView.center = self.trayCenterWhenOpen
                self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: 0.0)
                self.view.layoutIfNeeded()
            },
            completion: { (done: Bool) -> Void in
                self.isTrayOpen = true
                dlog("trayView.center: \(self.trayView.center), topFrame: \(self.trayView.frame.origin.y)")

        })
    }

    @IBAction func onTrayTap(_ sender: UITapGestureRecognizer) {
        
        if isTrayOpen {
            closeMenu()
        }
        else {
            openMenu()
        }
    }
    
    @IBAction func onFacePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        let locationInView = panGestureRecognizer.location(in: self.view)
        // Gesture recognizers know the view they are attached to
        let imageView = panGestureRecognizer.view as! UIImageView
        
        if panGestureRecognizer.state == .began {
        
            faceStartPoint = locationInView
            dlog("Gesture began \(imageView.tag), faceStart: \(faceStartPoint)")
            
            // Create a new image view that has the same image as the one currently panning
            newlyCreatedFaceImageView = UIImageView(image: imageView.image)
            newlyCreatedFaceImageView.isUserInteractionEnabled = true
            let newFacePanner = UIPanGestureRecognizer(target: self, action: #selector(onNewFacePan(_:)))
            newlyCreatedFaceImageView.addGestureRecognizer(newFacePanner)
            
            let newFacePincher = UIPinchGestureRecognizer(target: self, action: #selector(onNewFacePinch(_:)))
            newlyCreatedFaceImageView.addGestureRecognizer(newFacePincher)
            newFacePincher.delegate = self
            
            let newFaceRotater = UIRotationGestureRecognizer(target: self, action: #selector(onNewFaceRotate(_:)))
            newlyCreatedFaceImageView.addGestureRecognizer(newFaceRotater)
            newFaceRotater.delegate = self
            
            // Add the new face to the tray's parent view.
            view.addSubview(newlyCreatedFaceImageView)
            
            // Initialize the position of the new face.
            newlyCreatedFaceImageView.center = imageView.center
            
            // Since the original face is in the tray, but the new face is in the
            // main view, you have to offset the coordinates
            newlyCreatedFaceImageView.center.y += trayView.frame.origin.y
        }
        else if panGestureRecognizer.state == .changed {
            newlyCreatedFaceImageView.center = locationInView
            dlog("Gesture changed \(newlyCreatedFaceImageView.center), faceStart: \(locationInView)")

        }
        else if panGestureRecognizer.state == .ended {
            //470.5
            
            if (newlyCreatedFaceImageView.frame.origin.y + newlyCreatedFaceImageView.frame.width) >= 470.5 {
                let options: UIViewAnimationOptions = .curveEaseInOut
                
                UIView.animate(withDuration: 0.5, delay: 0, options: options,
                               animations: { () -> Void in
                                //self.newlyCreatedFaceImageView.alpha = 0
                                let origCenterPoint = CGPoint(x: imageView.center.x, y:imageView.center.y + self.trayView.frame.origin.y)
                                self.newlyCreatedFaceImageView.center = origCenterPoint
                                self.trayView.layoutIfNeeded()
                    },
                               completion: { (done: Bool) -> Void in
                                self.newlyCreatedFaceImageView.removeFromSuperview()
                })

                
            }
            
            
        }
        else if panGestureRecognizer.state == .cancelled {
            
        }
    }
    
    @IBAction func onNewFacePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        let locationInView = panGestureRecognizer.location(in: self.view)
        guard let faceImageView = panGestureRecognizer.view as? UIImageView else {
            return
        }
        if panGestureRecognizer.state == .began {
            faceStartPoint = locationInView
            faceStartTransform = faceImageView.transform
            dlog("Gesture began \(faceImageView.center), faceStart: \(locationInView)")
            
            let options: UIViewAnimationOptions = .curveEaseInOut
            
            UIView.animate(withDuration: 0.1, delay: 0, options: options,
                animations: { () -> Void in
                    faceImageView.transform = self.faceStartTransform.scaledBy(x: 1.1, y: 1.1)
                    faceImageView.layoutIfNeeded()
                },
                completion: { (done: Bool) -> Void in
            })
        }
        else if panGestureRecognizer.state == .changed {
            dlog("Gesture changed \(faceImageView.center), faceStart: \(locationInView)")
            faceImageView.center = locationInView
        }
        else if panGestureRecognizer.state == .ended {
            dlog("Gesture ended \(faceImageView.center), faceStart: \(locationInView)")
            let options: UIViewAnimationOptions = .curveEaseOut
            UIView.animate(withDuration: 0.2, delay: 0, options: options,
                animations: { () -> Void in
                    faceImageView.transform = self.faceStartTransform
                    faceImageView.layoutIfNeeded()
                },
                completion: { (done: Bool) -> Void in
            })

        }
        else if panGestureRecognizer.state == .cancelled {
            dlog("Gesture cancelled \(faceImageView.center), faceStart: \(locationInView)")
            faceImageView.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func onNewFacePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        
        let locationInView = pinchGestureRecognizer.location(in: self.view)
        let scale = pinchGestureRecognizer.scale
        guard let faceImageView = pinchGestureRecognizer.view as? UIImageView else {
            return
        }
        
        if pinchGestureRecognizer.state == .began {
            faceStartPoint = locationInView
            dlog("Gesture began \(faceImageView.center), faceStart: \(locationInView)")
            
        }
        else if pinchGestureRecognizer.state == .changed {
            dlog("Gesture changed \(faceImageView.center), faceStart: \(locationInView)")
            faceImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        else if pinchGestureRecognizer.state == .ended {
            dlog("Gesture ended \(faceImageView.center), faceStart: \(locationInView)")
            
        }
        else if pinchGestureRecognizer.state == .cancelled {
            dlog("Gesture cancelled \(faceImageView.center), faceStart: \(locationInView)")
            faceImageView.transform = CGAffineTransform.identity
        }

    }
    
    @IBAction func onNewFaceRotate(_ rotateGestureRecognizer: UIRotationGestureRecognizer) {
        
        let locationInView = rotateGestureRecognizer.location(in: self.view)
        let rotation = rotateGestureRecognizer.rotation

        guard let faceImageView = rotateGestureRecognizer.view as? UIImageView else {
            return
        }
        
        if rotateGestureRecognizer.state == .began {
            faceStartPoint = locationInView
            faceStartRotationTransform = faceImageView.transform

            dlog("Gesture began \(faceImageView.center), faceStart: \(locationInView)")
            
        }
        else if rotateGestureRecognizer.state == .changed {
            dlog("Gesture changed \(faceImageView.center), faceStart: \(locationInView)")
            faceImageView.transform = faceStartRotationTransform.rotated(by: rotation)

        }
        else if rotateGestureRecognizer.state == .ended {
            dlog("Gesture ended \(faceImageView.center), faceStart: \(locationInView)")
            
        }
        else if rotateGestureRecognizer.state == .cancelled {
            dlog("Gesture cancelled \(faceImageView.center), faceStart: \(locationInView)")
            faceImageView.transform = CGAffineTransform.identity
        }
        
    }

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        dlog("g1: \(gestureRecognizer), g2: \(otherGestureRecognizer)")
        return true
    }
}

