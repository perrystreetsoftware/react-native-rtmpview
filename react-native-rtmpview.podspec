require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNRtmpView"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  React Native RTMPView
		  Show RTMP views on iOS + Android using React Native
                   DESC
  s.homepage     = "https://github.com/perrystreetsoftware/react-native-rtmpview"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "author" => "eric@s*****.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/perrystreetsoftware/react-native-rtmpview.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency 'React'
  s.dependency 'libksygpulive/KSYGPUResource'
  s.dependency 'libksygpulive/libksygpulive'
  s.dependency 'PureLayout'
end
