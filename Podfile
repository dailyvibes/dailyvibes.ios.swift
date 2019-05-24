# Uncomment the next line to define a global platform for your project
 platform :ios, '12.1'

target 'Daily Vibes' do
  use_frameworks!

  # Pods for Daily Vibes
  pod 'Notepad', :git => 'https://github.com/ruddfawcett/Notepad.git', :branch => 'master'
  pod 'ContextMenu', :git => 'https://github.com/GitHawkApp/ContextMenu.git', :branch => 'master'

  pod 'SwiftyChrono', :path => '/Users/getaclue/dev/DailyVibes.iOS/SwiftyChrono'

  pod 'Disk'
  pod 'DeckTransition'
  pod 'GrowingTextView'
  pod 'SwiftEntryKit'
  pod 'Charts'
  pod 'SwiftTheme'
  pod 'Down'

  pod 'FSCalendar'
  pod 'MarkdownKit', :git => 'https://github.com/bmoliveira/MarkdownKit', :branch => 'master'

  pod 'SimulatorStatusMagic', :configurations => ['Debug']

  target 'Daily VibesTests' do
    inherit! :search_paths
    # Pods for testing
  end

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
