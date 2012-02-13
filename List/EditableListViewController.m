//
//  EditableListViewController.m
//
//  Created by Yonat Sharon on 12/2/12.
//  Copyright (c) 2012 Roy Sharon Ltd. All rights reserved.
//

#import "EditableListViewController.h"

static NSString *inactiveTextFieldHint = @"Tap to add item";
static NSString *activeTextFieldHint = @"Type to add item";


@interface EditableListViewController () <UITextFieldDelegate> {
    NSMutableArray *rowsContent;
}
@end

@implementation EditableListViewController

#pragma Contents Assignment

- (NSArray *)contents
{
    return rowsContent; // toDO: should use arrayWithArray:?
}

- (void)setContents:(NSArray *)contents
{
    rowsContent = [NSMutableArray arrayWithArray:contents];
    [self.tableView reloadData];
}

#pragma mark - Table Changes

- (void)deleteRow:(NSIndexPath *)indexPath
{
    [rowsContent removeObjectAtIndex:indexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

- (void)addRow:(NSIndexPath *)indexPath text:(NSString *)text
{
    if (rowsContent == nil) {
        rowsContent = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [rowsContent addObject:text];
    NSIndexPath *nextRow = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextRow] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowsContent.count + 1; // extra one for inserting new row
}

- (UITextField *)createTextFieldForCell:(UITableViewCell *)cell
{
    CGRect frame = CGRectInset(cell.contentView.bounds, 8.0f, 2.0f);
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    CGFloat d = frame.size.height - textField.font.pointSize - 2;
    frame.origin.y += d;
    frame.size.height -=d;
    textField.frame = frame;
    textField.tag = TAG_TEXT_FIELD;
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return textField;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = CELL_REUSE_IDENTIFIER;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
    if (textField == nil) {
        textField = [self createTextFieldForCell:cell];
        [cell.contentView addSubview:textField];
    }
    textField.delegate = self;
    if (indexPath.row < rowsContent.count) {
        textField.text = [rowsContent objectAtIndex:indexPath.row];
        textField.placeholder = nil;
    } else {
        textField.text = nil;
        textField.placeholder = NSLocalizedString(inactiveTextFieldHint, nil);
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {

        case UITableViewCellEditingStyleDelete: {
            [self deleteRow:indexPath];
            break;
        }
            
        case UITableViewCellEditingStyleInsert: {
            UITableViewCell *sourceCell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *textField = [sourceCell viewWithTag:TAG_TEXT_FIELD];
            [textField becomeFirstResponder];
            break;
        }
            
        case UITableViewCellEditingStyleNone:
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *rowToMove = [rowsContent objectAtIndex:fromIndexPath.row];
    [rowsContent removeObjectAtIndex:fromIndexPath.row];
    [rowsContent insertObject:rowToMove atIndex:toIndexPath.row];
}

#pragma mark - Table View Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < rowsContent.count ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < rowsContent.count;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        textField.placeholder = NSLocalizedString(activeTextFieldHint, nil);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    UITableViewCell *parentCell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *currRow = [self.tableView indexPathForCell:parentCell];
    NSUInteger cellIndex = currRow.row;
    if (cellIndex < rowsContent.count) {
        if ([textField.text length]) {
            [rowsContent replaceObjectAtIndex:cellIndex withObject:textField.text];
        }
        else {
            [self deleteRow:currRow];
        }
    }
    else { // new row
        if ([textField.text length]) {
            [self addRow:currRow text:textField.text];
        }
        else {
            textField.placeholder = NSLocalizedString(inactiveTextFieldHint, nil);
        }
    }
	return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
