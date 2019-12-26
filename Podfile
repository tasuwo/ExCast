platform :ios, '12.2'

abstract_target 'All' do
  use_frameworks!

  target 'ExCast' do
    pod 'MaterialComponents'
    pod 'ObjectMapper', '~> 3.4'
    pod 'RxSwift', '~> 5.0.0'
    pod 'RxCocoa', '~> 5.0.0'
    pod 'RxDataSources', '~> 4.0'
    pod 'SwiftFormat/CLI'
  end

  target 'Domain' do
    pod 'RxDataSources', '~> 4.0'
  end

  target 'Infrastructure' do
    pod 'AWSSNS'
    pod 'RxSwift', '~> 5.0.0'
    pod 'RxCocoa', '~> 5.0.0'
    pod 'RealmSwift'

    pod 'Sourcery'
  end
end

plugin 'cocoapods-keys', {
  :project => "ExCast",
  :keys => [
    "AwsSnsApplicationArn",
    "AwsAccessKey",
    "AwsSecretKey"
  ]
}
