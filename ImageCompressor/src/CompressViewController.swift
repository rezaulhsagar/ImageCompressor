//
//  CompressViewController.swift
//  ImageCompressor
//

import UIKit

class CompressViewController: UIViewController {
    
    var image: UIImage!
    var resizedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblDimension: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBAction func btnExport(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Save finished!")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizedImage = image
        
        if checkSizeGreaterThan2160(size: image.size) { // At least one side is greater than 2160
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // for comparison, getting previous data without compression. e.g.: quality is set to 1.0
            let previousDimension = CGSize(width: image.size.width, height: image.size.height)
            let imgData = NSData(data: image.jpegData(compressionQuality: 1.0)!)
            let imageSizeKB: Int = Int(Double(imgData.count) / 1024.0)
            
            resizedImage = image.resize(minLength: 2160) // here dimension requirements are met
            let resizedImgData = NSData(data: resizedImage.jpegData(compressionQuality: 1.0)!)
            let resizedImageSizeKB: Int = Int(Double(resizedImgData.count) / 1024.0)
            
            if resizedImageSizeKB > 1024 { // we are processing with larger than 1mb images
                let compressedImage = ImageCompressor.getCompressedImage(image: image, x: 2160)
                
                let newDimension = CGSize(width: compressedImage.size.width, height: compressedImage.size.height)
                let compressedImgData = NSData(data: compressedImage.jpegData(compressionQuality: 0.9)!)
                let compressedImageSizeKB: Int = Int(Double(compressedImgData.count) / 1024.0)
                
                let endTime = CFAbsoluteTimeGetCurrent()
                let executionTime = round((endTime - startTime) * 100) / 100.0
                
                // Label info update
                self.lblDimension.text = "(\(Int(previousDimension.width)), \(Int(previousDimension.height))) -> (\(Int(newDimension.width)), \(Int(newDimension.height)))"
                // checking file size, update with smaller sized image
                if compressedImageSizeKB < resizedImageSizeKB {
                    self.lblSize.text = "\(imageSizeKB) KB -> \(compressedImageSizeKB) KB"
                    imageView.image = compressedImage
                } else {
                    self.lblSize.text = "\(imageSizeKB) KB -> \(resizedImageSizeKB) KB"
                    imageView.image = resizedImage
                }
                self.lblTime.text = "Execution time: \(executionTime) s"
                
            } else {
                imageView.image = resizedImage
                self.lblTime.text = "Execution Skipped. File less than 1 MB"
            }
        } else {
            imageView.image = image
            self.lblTime.text = "Execution skipped. Image less than 2160 px"
        }
        
    }
    
    func checkSizeGreaterThan2160(size: CGSize) -> Bool {
        return size.width > 2160 || size.height > 2160
    }
    

}
