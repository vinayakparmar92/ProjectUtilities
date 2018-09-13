#
# Be sure to run `pod lib lint ProjectUtilities.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ProjectUtilities'
  s.version          = '0.1'
  s.summary          = 'Every new project iOS project needs few code snippets and libraries to get started with. This project has got almost everything for that.'
  s.description      = <<-DESC
'The projects has got alot of helper methods and Extensions. It also has wrappers to make network calls. No need to big network library like Alamofire if you just need basic REST calls'
                       DESC
  s.homepage         = 'https://github.com/vinayakparmar92/ProjectUtilities'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vinayakparmar92' => 'vinayakparmar1992@gmail.com' }
  s.source           = { :git => 'https://github.com/vinayakparmar92/ProjectUtilities.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vinayakparmar92'
  s.ios.deployment_target = '9.0'
  s.source_files = 'ProjectUtilities/Classes/**/*'
end
