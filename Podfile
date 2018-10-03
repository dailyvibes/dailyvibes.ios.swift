# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'Daily Vibes' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Daily Vibes
  pod 'Notepad', :path => '/Users/getaclue/dev/DailyVibes.iOS/Notepad/'
  pod 'SwiftyChrono', :path => '/Users/getaclue/dev/DailyVibes.iOS/SwiftyChrono'
  # pod "ILLoginKit", :path => '/Users/getaclue/dev/DailyVibes.iOS/LoginKit'
  
  pod 'Disk'
  pod 'DeckTransition'
  pod 'GrowingTextView'
  
  pod 'Charts'
  pod 'SwiftTheme'
  pod 'Down'
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
  
  # pod 'EFMarkdown' - potential candidate Feb 2018
  # pod 'MarkdownView'
  # pod 'MarkdownKit'
  # pod 'Haring' # is the updated MarkdownKit
  # pod 'SwiftSpinner' # while i figure out why the delay is there
  # pod 'MarkdownTextView' - not in cocoapods Feb 2018
  # pod 'Notepad' - not updated for Swift 4 Feb 2018
  # pod 'Eureka'

  # target 'Daily VibesTests' do
  #   inherit! :search_paths
  #   # Pods for testing
  # end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        plist_buddy = "/usr/libexec/PlistBuddy"
        plist = "Pods/Target Support Files/#{target}/Info.plist"
        `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities array" "#{plist}"`
        `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities:0 string arm64" "#{plist}"`
    end
end

ENV['COCOAPODS_DISABLE_STATS'] = 'true'
