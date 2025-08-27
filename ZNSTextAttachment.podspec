Pod::Spec.new do |s|
  s.name             = 'ZNSTextAttachment'
  s.version          = '2.0.1'
  s.summary          = 'ZNSTextAttachment enables NSTextAttachment to download images from remote URLs, supporting both UITextView and UILabel.'
  s.description      = <<-DESC
    ZNSTextAttachment enables NSTextAttachment to download images from remote URLs, supporting both UITextView and UILabel. Part of ZMarkupParser. Pure-Swift library for HTML to NSAttributedString conversion with custom style and tags.
  DESC
  s.homepage         = 'https://github.com/BudhirajaRajesh/ZNSTextAttachment'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZRealm' => 'zhgchgli@gmail.com' }
  s.source           = { :git => 'https://github.com/BudhirajaRajesh/ZNSTextAttachment.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files     = 'Sources/**/*.{swift}'
  s.swift_version    = '5.7'
  s.frameworks       = 'UIKit'
  s.requires_arc     = true
  s.module_name      = 'ZNSTextAttachment'
  s.resource_bundles = {}
end 