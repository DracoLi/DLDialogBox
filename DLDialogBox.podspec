Pod::Spec.new do |s|
s.name         = "DLDialogBox"
  s.version      = "0.1"
  s.summary      = "Easy dialog creation for your iOS cocos2d game."
  s.homepage     = "http://dracoli.github.io/DLDialogBox"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Draco Li" => "draco@dracoli.com" }
  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/DracoLi/DLDialogBox.git", :tag => s.version.to_s }
  s.source_files  = 'DLDialogBox/*.{h,m}'
  s.private_header_files = 'Helpers/*.h'
  s.resources = 'DLDialogBox/DLDialogBox.bundle'
end
