
Pod::Spec.new do |s|

  s.name         = "RSMasterTableView"
  s.version      = "1.0"
  s.summary      = "A powerful UITableView with inbuilt PullToRefresh and Load More functionality."
  s.description  = <<-DESC
   RSMasterTableView can be used a normal tableView as well as with PullToRefresh and Infinite Scrolling. No need to write complex code to manage data and paging structure
                   DESC
  s.homepage     = "https://github.com/rushisangani/RSMasterTableView"
  s.requires_arc = true
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Rushi Sangani" => "rushisangani@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/rushisangani/RSMasterTableView.git", :tag => "1.0" }
  s.source_files  = "RSMasterTableView", "RSMasterTableView/**/*.{h,m}"
end