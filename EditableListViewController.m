//
//  EditableListViewController.m
//
//  Created by Yonat Sharon on 12/2/12.
//

#import "EditableListViewController.h"

static NSString *inactiveTextFieldHint = @"Tap to add item";
static NSString *activeTextFieldHint = @"";
static NSString *returnTappedTextFieldHint = @"~"; // HACK to mark when return was tapped

#pragma mark - Helper Categories

@interface UITextField (ChangeReturnKey)
- (void)changeReturnKey:(UIReturnKeyType)returnKeyType;
@end

@implementation UITextField (ChangeReturnKey)
- (void)changeReturnKey:(UIReturnKeyType)returnKeyType
{
    self.returnKeyType = returnKeyType;
    [self reloadInputViews];
}
@end

#pragma mark - EditableListViewController

@interface EditableListViewController () <UITextFieldDelegate> {
    NSMutableArray *rowsContent;
}
@end

@implementation EditableListViewController

#pragma mark - Contents Assignment

- (NSArray *)contents
{
    return rowsContent;
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
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self contentsDidChange];
}

- (void)addRow:(NSIndexPath *)indexPath text:(NSString *)text
{
    if (rowsContent == nil) {
        rowsContent = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [rowsContent addObject:text];
    NSIndexPath *nextRow = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextRow] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self contentsDidChange];
}

- (void)contentsDidChange
{
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
    CGFloat padding = 8.0f;
    CGRect frame = CGRectInset(cell.contentView.bounds, padding, padding / 2);
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    CGFloat spareHeight = cell.contentView.bounds.size.height - textField.font.pointSize;
    frame.origin.y = self.tableView.style == UITableViewStyleGrouped ? spareHeight / 2 : spareHeight - padding/2;
    textField.frame = frame;
    textField.tag = TAG_TEXT_FIELD;
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
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
        textField.text = rowsContent[indexPath.row];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 && indexPath.row < rowsContent.count;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *rowContent = [rowsContent objectAtIndex:fromIndexPath.row];
    [rowsContent removeObjectAtIndex:fromIndexPath.row];
    [rowsContent insertObject:rowContent atIndex:toIndexPath.row];
    [self contentsDidChange];
}

#pragma mark - Table View Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) return UITableViewCellEditingStyleNone;
    return indexPath.row < rowsContent.count ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
    targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
    toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath.section == 0 && proposedDestinationIndexPath.row < rowsContent.count
        ? proposedDestinationIndexPath
        : [NSIndexPath indexPathForRow:rowsContent.count-1 inSection:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
    rowsContent[indexPath.row];
}

#pragma mark - UITextFieldDelegate

- (NSIndexPath *)cellIndexPathForField:(UITextField *)textField
{
    UIView *view = textField;
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    return [self.tableView indexPathForCell:(UITableViewCell *)view];
}

- (NSUInteger)rowIndexForField:(UITextField *)textField
{
    return [self cellIndexPathForField:textField].row;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        textField.placeholder = NSLocalizedString(activeTextFieldHint, nil);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.placeholder = returnTappedTextFieldHint;
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length == 0) {
        // if it's the last field, change the return key to "Next"
        if ([self rowIndexForField:textField] == rowsContent.count) {
            [textField changeReturnKey:UIReturnKeyNext];
        }
    }
    else {
        // if return button is "Next" and field is about to be empty, change to "Done"
        if (textField.returnKeyType == UIReturnKeyNext && string.length == 0 && range.length == textField.text.length) {
            [textField changeReturnKey:UIReturnKeyDone];
        }
    }

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        [textField changeReturnKey:UIReturnKeyDone];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *currRow = [self cellIndexPathForField:textField];
    NSUInteger cellIndex = currRow.row;
    if (cellIndex < rowsContent.count) {
        if ([textField.text length]) {
            if (![textField.text isEqualToString:[rowsContent objectAtIndex:cellIndex]]) {
                [rowsContent replaceObjectAtIndex:cellIndex withObject:textField.text];
                [self contentsDidChange];
            }
        }
        else {
            [self deleteRow:currRow];
        }
    }
    else { // new row
        if ([textField.text length]) {
            [self addRow:currRow text:textField.text];
            [textField changeReturnKey:UIReturnKeyDone];
            if ([textField.placeholder isEqual:returnTappedTextFieldHint]) { // if tapped return, go to the next field
                UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex+1 inSection:currRow.section]];
                UIView *nextTextField = [nextCell viewWithTag:TAG_TEXT_FIELD];
                [nextTextField becomeFirstResponder];
            }
        }
        else {
            textField.placeholder = NSLocalizedString(inactiveTextFieldHint, nil);
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
