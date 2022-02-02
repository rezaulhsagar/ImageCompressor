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
        UIImageWriteToSavedPhotosAlbum(resizedImage, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Save finished!")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizedImage = image
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let previousDimension = CGSize(width: image.size.width, height: image.size.height)
        let imgData = NSData(data: image.jpegData(compressionQuality: 0.9)!)
        var imageSizeKB: Int = Int(Double(imgData.count) / 1000.0)
        
        resizedImage = ImageCompressor.getCompressedImage(image: image, x: 2160)
        imageView.image = resizedImage
        
        var newDimension = CGSize(width: resizedImage.size.width, height: resizedImage.size.height)
        var imgData2 = NSData(data: resizedImage.jpegData(compressionQuality: 0.9)!)
        var imageSizeKB2: Int = Int(Double(imgData2.count) / 1000.0)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = round((endTime - startTime) * 100) / 100.0
        
        self.lblDimension.text = "(\(Int(previousDimension.width)), \(Int(previousDimension.height))) -> (\(Int(newDimension.width)), \(Int(newDimension.height)))"
        self.lblSize.text = "\(imageSizeKB) KB -> \(imageSizeKB2) KB"
        self.lblTime.text = "Execution time: \(executionTime) s"
        
    }
    

}
