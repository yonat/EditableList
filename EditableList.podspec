
Pod::Spec.new do |s|

  s.name         = "EditableList"
  s.version      = "1.0.0"
  s.summary      = "Simple List of UITextField-s based on UITableViewController"

  s.description  = <<-DESC
A simple list of text fields, similar to Reminders.app, featuring:

- Inline editing.
- Adding a new row by tapping below the last row.
- Edit mode with list reordering.
- Supports both plain style and grouped style UITableView.
                   DESC

  s.homepage     = "https://github.com/yonat/EditableList"
  s.screenshots  = "http://ootips.org/yonat/wp-content/uploads/2012/02/EditableList.png"

  s.license      = { :type => "MIT", :file => "LICENSE.txt" }

  s.author             = { "Yonat Sharon" => "yonat@ootips.org" }
  s.social_media_url   = "http://twitter.com/yonatsharon"

  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/yonat/EditableList.git", :tag => "1.0.0" }

  s.source_files  = "EditableListViewController.{h,m}"

  s.requires_arc = true
end
