Pod::Spec.new do |s|
  s.name             = "ZNSTextAttachment"
  s.version          = "1.1.7"
  s.summary          = "ZNSTextAttachment enables NSTextAttachment to download images from remote URLs."
  s.homepage         = "https://github.com/ZhgChgLi/ZNSTextAttachment"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "ZhgChgLi" => "me@zhgchg.li" }
  s.source           = { :git => "https://github.com/ZhgChgLi/ZNSTextAttachment.git", :tag => "v" + s.version.to_s }
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "12.0"
  s.swift_version = "5.0"
  s.source_files = ["Sources/**/*.swift"]
end
