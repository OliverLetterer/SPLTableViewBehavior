#
# Be sure to run `pod lib lint SPLTableViewBehavior.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SPLTableViewBehavior"
  s.version          = "0.7.1"
  s.summary          = "Define a UITableView behavior with lightweight, reusable and composable components."
  s.homepage         = "https://github.com/OliverLetterer/SPLTableViewBehavior"
  s.license          = 'MIT'
  s.author           = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.source           = { :git => "https://github.com/OliverLetterer/SPLTableViewBehavior.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oletterer'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'SPLTableViewBehavior', 'SPLTableViewBehavior/Private'
  s.private_header_files = "SPLTableViewBehavior/Private/*.h"

  s.frameworks = 'UIKit'
end
