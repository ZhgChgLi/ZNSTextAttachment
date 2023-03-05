//
//  UILabelsViewController.swift
//  ZNSTextAttachment-Demo
//
//  Created by https://zhgchg.li on 2023/3/5.
//

import UIKit
import ZNSTextAttachment

class UILabelsViewController: UIViewController {

    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://zhgchg.li/assets/a5643de271e4/1*A0yXupXW9-F9ZWe4gp2ObA.jpeg")!, placeholderImage: UIImage(systemName: "viewfinder.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal))
        
        let data = TestData.generate(with: attachment)
        
        attachment.dataSource = self
        attachment.delegate = self
        
        attachment.register(label: label1)
        attachment.register(label: label2)
        
        label1.attributedText = data
        label2.attributedText = data
    }
}

extension UILabelsViewController: ZNSTextAttachmentDataSource {
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


extension UILabelsViewController: ZNSTextAttachmentDelegate {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment) {
        //
    }
}
