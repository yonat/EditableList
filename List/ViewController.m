//
//  ViewController.m
//  List
//
//  Created by Yonat Sharon on 12/2/12.
//  Copyright (c) 2012 Roy Sharon Ltd. All rights reserved.
//

#import "ViewController.h"

@interface UITableView (CellAccess)
- (UITableViewCell *)visibleCellForIndexPath:(NSIndexPath *)indexPath;
@end
@implementation UITableView (CellAccess)
- (UITableViewCell *)visibleCellForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cells = [self visibleCells];
    for (UITableViewCell *cell in cells) {
        if ([[self indexPathForCell:cell] isEqual:indexPath]) {
            return cell;
        }
    }
    return nil;
}
@end

@interface ViewController () <UITextFieldDelegate> {
    NSMutableArray *rowsContent;
}
@end

@implementation ViewController

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowsContent.count + 1; // extra one for inserting new row
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"TextCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    UITextField *textField = (UITextField *)[cell viewWithTag:100];
    textField.delegate = self;
    textField.text = indexPath.row < rowsContent.count ? [rowsContent objectAtIndex:indexPath.row] : nil;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {

        case UITableViewCellEditingStyleDelete: {
            [rowsContent removeObjectAtIndex:indexPath.row];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            break;
        }
            
        case UITableViewCellEditingStyleInsert: {
            UITableViewCell *sourceCell = [tableView visibleCellForIndexPath:indexPath];
            UIView *textField = [sourceCell viewWithTag:100];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    UITableViewCell *parentCell = (UITableViewCell *)[[textField superview] superview];
    NSUInteger cellIndex = [self.tableView indexPathForCell:parentCell].row;
    if (cellIndex < rowsContent.count) {
        [rowsContent replaceObjectAtIndex:cellIndex withObject:textField.text];
    }
    else {
        [rowsContent addObject:textField.text];
        NSIndexPath *currRow = [NSIndexPath indexPathForRow:cellIndex inSection:0];
        NSIndexPath *nextRow = [NSIndexPath indexPathForRow:cellIndex+1 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:currRow] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextRow] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
    }
	return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	rowsContent = [NSMutableArray arrayWithObjects:@"First note", @"Another one", nil];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
