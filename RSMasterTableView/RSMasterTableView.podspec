
Pod::Spec.new do |s|

  s.name         = "RSMasterTableView"
  s.version      = "1.0"
  s.summary      = "A powerful UITableView with inbuilt PullToRefresh and Load More functionality."
  s.description  = "A powerful UITableView with inbuilt PullToRefresh and Load More functionality."
  s.homepage     = "https://github.com/rushisangani/RSMasterTableView"
  s.requires_arc = true
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Rushi Sangani" => "rushis@meditab.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/rushisangani/RSMasterTableView.git", :tag => "#{s.version}" }
  s.source_files  = "RSMasterTableView", "RSMasterTableView/**/*.{h,m,swift}"
  s.requires_arc = true

end
