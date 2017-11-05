//
//  DrawItViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 05/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

class DrawItViewController: UIViewController {
    
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    
    public var drawItImageView: UIImageView!
    public var status: Bool = false
    
    @IBAction func saveDrawnImage(_ sender: Any) {
        self.status = true
        self.canvasView?.save()
        self.status = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func initialize() {
        self.setupCanvas()
        self.setupPalette()
        self.setupToolBar()
    }
    
    fileprivate func setupPalette() {
        self.view.backgroundColor = UIColor.white
        
        let paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        self.view.addSubview(paletteView)
        self.paletteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0, y: self.view.frame.height - paletteHeight, width: self.view.frame.width, height: paletteHeight)
    }
    
    fileprivate func setupToolBar() {
        let height = (self.paletteView?.frame)!.height * 0.25
        let startY = self.view.frame.height - (paletteView?.frame)!.height - height
        let toolBar = ToolBar()
        toolBar.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
        toolBar.undoButton?.addTarget(self, action: #selector(DrawItViewController.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(DrawItViewController.onClickRedoButton), for: .touchUpInside)
        toolBar.loadButton?.addTarget(self, action: #selector(DrawItViewController.onClickLoadButton), for: .touchUpInside)
        toolBar.saveButton?.addTarget(self, action: #selector(DrawItViewController.onClickSaveButton), for: .touchUpInside)
        // default title is "Save"
        toolBar.saveButton?.setTitle("Post", for: UIControlState())
        toolBar.clearButton?.addTarget(self, action: #selector(DrawItViewController.onClickClearButton), for: .touchUpInside)
        toolBar.loadButton?.isEnabled = true
        self.view.addSubview(toolBar)
        self.toolBar = toolBar
    }
    
    fileprivate func setupCanvas() {
        //        let canvasView = Canvas(backgroundImage: UIImage.init(named: "frame")!) // You can init with custom background image
        let canvasView = Canvas()
        canvasView.frame = CGRect(x: 20, y: 80, width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 140)
        canvasView.delegate = self
        canvasView.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
        canvasView.layer.borderWidth = 2.0
        canvasView.layer.cornerRadius = 5.0
        canvasView.clipsToBounds = true
        canvasView.update(self.drawItImageView?.image)
        self.view.addSubview(canvasView)
        self.canvasView = canvasView
    }
    
    fileprivate func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.saveButton?.isEnabled = canvas.canSave()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    @objc func onClickUndoButton() {
        self.canvasView?.undo()
    }
    
    @objc func onClickRedoButton() {
        self.canvasView?.redo()
    }
    
    @objc func onClickLoadButton() {
        self.showActionSheetForPhotoSelection()
    }
    
    @objc func onClickSaveButton() {
        self.canvasView?.save()
    }
    
    @objc func onClickClearButton() {
        self.canvasView?.clear()
        self.canvasView?.update(nil)
    }
    
    
    // MARK: - Image and Photo selection
    fileprivate func showActionSheetForPhotoSelection() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Photo from Album", "Take a Photo")
        actionSheet.show(in: self.view)
    }
    
    fileprivate func showPhotoLibrary () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage)]
        
        self.present(picker, animated: true, completion: nil)
    }
    
    fileprivate func showCamera() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch (status) {
        case .notDetermined:
            self.presentImagePickerController()
            break
        case .restricted, .denied:
            self.showAlertForImagePickerPermission()
            break
        case .authorized:
            self.presentImagePickerController()
            break
        }
    }
    
    fileprivate func showAlertForImagePickerPermission() {
        let message = "If you want to use camera, you should allow app to use.\nPlease check your permission"
        let alert = UIAlertView(title: "", message: message, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Allow")
        alert.show()
    }
    
    fileprivate func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    fileprivate func presentImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = [String(kUTTypeImage)]
            self.present(picker, animated: true, completion: nil)
        } else {
            let message = "This device doesn't support a camera"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafeRawPointer)       {
        if didFinishSavingWithError != nil {
            let message = "Saving failed"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        } else {
            let message = "Saved successfuly"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
}


// MARK: - CanvasDelegate
extension DrawItViewController: CanvasDelegate
{
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        // you can save merged image
        //        if let pngImage = image?.asPNGImage() {
        //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(DrawItDrawItViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        // you can save strokeImage
        //        if let pngImage = drawing.stroke?.asPNGImage() {
        //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(DrawItViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        //        self.updateToolBarButtonStatus(canvas)
        
        // you can share your image with UIActivityDrawItViewController
        if let pngImage = image?.asPNGImage() {
            drawItImageView.image = pngImage
            if self.status {
                return
            }
            let activityDrawItViewController = UIActivityViewController(activityItems: [pngImage], applicationActivities: nil)
            activityDrawItViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                }
                
                if activityType == UIActivityType.saveToCameraRoll {
                    let alert = UIAlertController(title: nil, message: "Image is saved successfully", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
            activityDrawItViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityDrawItViewController, animated: true, completion: nil)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension DrawItViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type = info[UIImagePickerControllerMediaType]
        if type as? String != String(kUTTypeImage) {
            return
        }
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true, completion: { [weak self] in
            let cropper = RSKImageCropViewController(image:selectedImage, cropMode:.square)
            cropper.delegate = self
            self?.present(cropper, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - RSKImageCropDrawItViewControllerDelegate
extension DrawItViewController: RSKImageCropViewControllerDelegate
{
    @objc(imageCropViewControllerDidCancelCrop:) func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc(imageCropViewController:didCropImage:usingCropRect:) func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.canvasView?.update(croppedImage)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIActionSheetDelegate
extension DrawItViewController: UIActionSheetDelegate
{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            return
        }
        
        if buttonIndex == 1 {
            self.showPhotoLibrary()
        } else if buttonIndex == 2 {
            self.showCamera()
        }
    }
}


// MARK: - UIAlertViewDelegate
extension DrawItViewController: UIAlertViewDelegate
{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return
        } else {
            self.openSettings()
        }
    }
}


// MARK: - PaletteDelegate
extension DrawItViewController: PaletteDelegate
{
    //    func didChangeBrushColor(color: UIColor) {
    //
    //    }
    //
    //    func didChangeBrushAlpha(alpha: CGFloat) {
    //
    //    }
    //
    //    func didChangeBrushWidth(width: CGFloat) {
    //
    //    }
    
    
    // tag can be 1 ... 12
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.clear
        }
        return nil
    }
    
    // tag can be 1 ... 4
    //    func widthWithTag(tag: NSInteger) -> CGFloat {
    //        if tag == 1 {
    //            return 5.0
    //        }
    //        return -1
    //    }
    // tag can be 1 ... 3
    //    func alphaWithTag(tag: NSInteger) -> CGFloat {
    //        return -1
    //    }
}


