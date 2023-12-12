//
//  UITextViewsViewController.swift
//  ZNSTextAttachment-Demo
//
//  Created by https://zhgchg.li on 2023/3/5.
//

import UIKit
import ZNSTextAttachment

class UITextViewsViewController: UIViewController {

    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    @IBOutlet weak var textView3: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://cdn.sspai.com/editor/u_/clp6gmdb34tb3fodr3a0?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1")!, placeholderImage: UIImage(systemName: "viewfinder.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal))
        
        let data = TestData.generate(with: attachment)
        
        attachment.dataSource = self
        attachment.delegate = self
        
        textView1.attributedText = data
        textView2.attributedText = data
        textView3.attributedText = data
    }
}

extension UITextViewsViewController: ZNSTextAttachmentDataSource {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: URL(string: imageURL.absoluteString)!) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            completion(data, response?.mimeType)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dataTask.resume()
        }
    }
}


extension UITextViewsViewController: ZNSTextAttachmentDelegate {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        //
    }
}
