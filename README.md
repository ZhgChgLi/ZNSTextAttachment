# ZNSTextAttachment

ZNSTextAttachment enables NSTextAttachment to download images from remote URLs, support both UITextView and UILabel.

- part of [ZMarkupParser](https://github.com/ZhgChgLi/ZMarkupParser)

# Installation
## Swift Package Manager

```
File > Swift Packages > Add Package Dependency
Add https://github.com/ZhgChgLi/ZNSTextAttachment.git
Select "Up to Next Major" with "1.1.9"
```
or
```swift
...
dependencies: [
  .package(url: "https://github.com/ZhgChgLi/ZNSTextAttachment.git", from: "1.1.9"),
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
  pod 'ZNSTextAttachment', '~> 1.1.9'
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

## About
- [ZhgChg.Li](https://zhgchg.li/)
- [ZhgChgLi's Medium](https://blog.zhgchg.li/)

## Other works
### Swift Libraries
- [ZMarkupParser](https://github.com/ZhgChgLi/ZMarkupParser) is a pure-Swift library that helps you to convert HTML strings to NSAttributedString with customized style and tags.
- [ZPlayerCacher](https://github.com/ZhgChgLi/ZPlayerCacher) is a lightweight implementation of the AVAssetResourceLoaderDelegate protocol that enables AVPlayerItem to support caching streaming files.

### Integration Tools
- [XCFolder](https://github.com/ZhgChgLi/XCFolder) is a powerful command-line tool that converts Xcode virtual groups into actual directories, reorganizing your project structure to align with Xcode groups and enabling seamless integration with modern Xcode project generation tools like Tuist and XcodeGen.
- [ZReviewTender](https://github.com/ZhgChgLi/ZReviewTender) is a tool for fetching app reviews from the App Store and Google Play Console and integrating them into your workflow.
- [ZMediumToMarkdown](https://github.com/ZhgChgLi/ZMediumToMarkdown) is a powerful tool that allows you to effortlessly download and convert your Medium posts to Markdown format.
- [linkyee](https://github.com/ZhgChgLi/linkyee) is a fully customized, open-source LinkTree alternative deployed directly on GitHub Pages.

# Donate

[![Buy Me A Coffe](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20beer!&emoji=%F0%9F%8D%BA&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/zhgchgli)

If you find this library helpful, please consider starring the repo or recommending it to your friends.

Feel free to open an issue or submit a fix/contribution via pull request. :)
