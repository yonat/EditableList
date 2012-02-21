//
//  EditableListViewController.h
//
//  Created by Yonat Sharon on 12/2/12.
//
//  Simple List, with inline editing and adding by typing the next row (a la Reminders.app)
//  Supports swipe-to-delete, and edit mode with move/delete/add.
//
//  To be notified on content changes, override contentsDidChange (does nothing by default).
//  To change properties of the text fields, either use a xib/storyboard or override createTextFieldForCell: .
//  To change placeholder text, edit your bundle's .strings file entries "Tap to add item" and "Type to add item".
//

#import <UIKit/UIKit.h>

// for use in xib/storyboard:
#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface EditableListViewController : UITableViewController

// list data:
@property (nonatomic, copy) NSArray *contents;

// methods for possible overriding:
- (void)contentsDidChange;
- (UITextField *)createTextFieldForCell:(UITableViewCell *)cell;

@end
