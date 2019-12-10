

Pod::Spec.new do |spec|

  spec.name         = "KKFlyView"

  spec.version      = '1.0.0'

  spec.summary      = "fly window and fly view"

  spec.description  = <<-DESC
fly view and window, just fly
DESC

  spec.homepage     = "https://github.com/onetys"

  spec.license      = "MIT"

  spec.author       = { "wangtieshan" => "onetys@163.com" }

  spec.platform     = :ios, "8.0"

  spec.source = { :path => 'https://github.com/onetys/KKFlyView.git', :tag => spec.version }

  spec.pod_target_xcconfig = { 'BITCODE_GENERATION_MODE' => 'bitcode', 'ENABLE_BITCODE' => 'YES' }

  spec.source_files = "KKFlyView/KKFlyView/**/*.{h,m,swift}"

  spec.resource  = "KKFlyView/KKFlyView/KKFlyView.bundle"
end
