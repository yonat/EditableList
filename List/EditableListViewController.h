//
//  EditableListViewController.h
//
//  Created by Yonat Sharon on 12/2/12.
//  Copyright (c) 2012 Roy Sharon Ltd. All rights reserved.
//
//  Simple List, with inline editing and adding by typing the next row (a la Reminders.app)
//  Supports swipe-to-delete, and edit mode with move/delete/add.
//
//  To change properties of the text fields, either use a xib/storyboard or override createTextFieldForCell: .
//  To change placeholder text, edit your bundle's .strings file entries "Tap to add item" and "Type to add item".
//

#import <UIKit/UIKit.h>

// for use in xib/storyboard:
#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface EditableListViewController : UITableViewController

@property (nonatomic, copy) NSArray *contents;

- (UITextField *)createTextFieldForCell:(UITableViewCell *)cell;

@end
