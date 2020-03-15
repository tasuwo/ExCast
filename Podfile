platform :ios, '13'

abstract_target 'All' do
  use_frameworks!

  target 'ExCast' do
    pod 'MaterialComponents'
    pod 'ObjectMapper',   '~> 3.4'
    pod 'RxSwift',        '~> 5.0.0'
    pod 'RxCocoa',        '~> 5.0.0'
    pod 'RxDataSources',  '~> 4.0'

    pod 'SwiftFormat/CLI'
    pod 'SwiftLint'
  end

  target 'Domain' do
    pod 'RxDataSources',  '~> 4.0'
  end

  target 'Infrastructure' do
    pod 'AWSSNS'

    pod 'RxSwift',        '~> 5.0.0'
    pod 'RxCocoa',        '~> 5.0.0'

    pod 'RealmSwift'
  end

  target 'InfrastructureTests' do
    pod 'Quick',           '~> 2.2.0'
    pod 'Nimble',          '~> 8.0.4'

    pod 'RxTest',          '~> 5.0.0'
    pod 'RxBlocking',      '~> 5.0.0'

    pod 'Sourcery'
  end

  target 'Common' do
    pod 'SwiftyBeaver',    '~> 1.8.4'
  end

  target 'SharedTestHelper' do
    pod 'RxSwift',        '~> 5.0.0'
    pod 'RxCocoa',        '~> 5.0.0'
    pod 'RealmSwift'
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
