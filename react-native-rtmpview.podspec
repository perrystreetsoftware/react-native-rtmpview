require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'react-native-rtmpview'
  s.version      = package['version']
  s.summary      = package['description']
  s.description  = package['summary']
  s.homepage     = 'https://github.com/perrystreetsoftware/react-native-rtmpview'
  s.license      = 'MIT'
  s.author       = { 'author' => 'eric@s*****.com' }
  s.platform     = :ios, '12.0'
  s.source       = { git: 'https://github.com/perrystreetsoftware/' \
                          'react-native-rtmpview.git',
                     tag: s.version.to_s }

  s.source_files = 'ios/*.{h,m}'
  s.requires_arc = true

  s.dependency 'React'
  s.dependency 'PureLayout'
  s.dependency 'AmazonIVSPlayer'
end
