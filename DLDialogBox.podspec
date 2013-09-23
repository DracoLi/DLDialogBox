Pod::Spec.new do |s|
s.name         = "DLDialogBox"
  s.version      = "0.1"
  s.summary      = "Easy dialog creation for your iOS cocos2d game."
  s.homepage     = "http://www.dracoli.com/DLDialogBox"
  # s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = 'MIT'
  s.author       = { "Draco Li" => "draco@dracoli.com" }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  # s.source       = { :git => "https://github.com/DracoLi/DLDialogBox.git", :tag => "0.0.1" }
  s.source       = { :git => "https://github.com/DracoLi/DLDialogBox.git" }
  s.source_files  = 'DLDialogBox/*.{h,m}'

  s.private_header_files = 'DLDialogBox/CCScale9Sprite.h', 'DLDialogBox/CCSprite+GLBoxes.h'
  s.resource_bundles = { 'DLDialogBox' => 'DLDialogBox/PresetResources/*.{png,plist,fnt}' }
  # s.resources = "DLDialogBox/PresetResources/*.{png,plist,fnt}"
end
