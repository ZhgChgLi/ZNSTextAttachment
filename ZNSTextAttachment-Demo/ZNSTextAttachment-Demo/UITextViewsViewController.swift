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
        
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://zhgchg.li/assets/a5643de271e4/1*A0yXupXW9-F9ZWe4gp2ObA.jpeg")!, placeholderImage: UIImage(systemName: "viewfinder.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal))
        
        let data = TestData.generate(with: attachment)
        
        attachment.dataSource = self
        attachment.delegate = self
        
        textView1.attributedText = data
        textView2.attributedText = data
        textView3.attributedText = data
    }
}

extension UITextViewsViewController: ZNSTextAttachmentDataSource {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: URL(string: imageURL.absoluteString+"?q=\(UUID().uuidString)")!) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            completion(data)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dataTask.resume()
        }
    }
}


extension UITextViewsViewController: ZNSTextAttachmentDelegate {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment) {
        
    }
}
