# ZNSTextAttachment

ZNSTextAttachment enables NSTextAttachment to download images from remote URLs, support both UITextView and UILabel.

- part of [ZMarkupParser](https://github.com/ZhgChgLi/ZMarkupParser)

# Installation
## Swift Package Manager

```
File > Swift Packages > Add Package Dependency
Add https://github.com/ZhgChgLi/ZNSTextAttachment.git
Select "Up to Next Major" with "1.1.6"
```
or
```swift
...
dependencies: [
  .package(url: "https://github.com/ZhgChgLi/ZNSTextAttachment.git", from: "1.1.6"),
]
...
.target(
    ...
    dependencies: [
        "ZNSTextAttachment",
    ],
    ...
)
```

## CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'ZNSTextAttachment', '~> 1.1.6'
end
```


# Usage
```swift

// ZNSTextAttachment with placeHolder Image
let attachment = ZNSTextAttachment(imageURL: URL(string: "https://zhgchg.li/assets/a5643de271e4/1*A0yXupXW9-F9ZWe4gp2ObA.jpeg")!, imageWidth: 300, placeholderImage: UIImage(systemName: "viewfinder.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal))

let attributedString = NSMutableAttributedString()
attributedString.append(NSAttributedString(string: "ZMarkupParser is a pure-Swift library that helps you to convert HTML strings to NSAttributedString with customized style and tags.\n"))
attributedString.append(NSAttributedString(string: "-  Parse HTML strings using pure-Swift and regular expressions.\n"))
attributedString.append(NSAttributedString(attachment: attachment))
        
attachment.dataSource = self // if not assign, will use URLSession as default
attachment.delegate = self
        
// UITextView:
textView.attributedText = attributedString

// ZNSTextAttachmentLabel, auto binding
label.attributedText = attributedString

// UILabel
attachment.register(label) // need binding
label.attributedText = attributedString
```

## Technical Detail

<img width="1450" alt="image" src="https://user-images.githubusercontent.com/33706588/224502652-d2448b48-d15c-4bcb-b6f1-9cdee839c99b.png">

Post: [手工打造 HTML 解析器的那些事(Traditional Chinese)](https://medium.com/zrealm-ios-dev/%E6%89%8B%E5%B7%A5%E6%89%93%E9%80%A0-html-%E8%A7%A3%E6%9E%90%E5%99%A8%E7%9A%84%E9%82%A3%E4%BA%9B%E4%BA%8B-2724f02f6e7)
