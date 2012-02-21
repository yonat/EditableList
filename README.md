**EditableListViewController - Simple List of UITextField-s based on UITableViewController**

A simple list of text fields, similar to Reminders.app, featuring:

- Inline editing.
- Adding a new row by tapping below the last row.
- Edit mode with list reordering.
- Supports both plain style and grouped style UITableView.

**Usage:** 

The simplest is to use `EditableListViewController` as-is:

- Access list contents using the `contents` property.
- Change list appearance by setting standard UITableView properties.
- Configure cells and text fields in a xib/storyboard.

For further customization, you can subclass it:

- Respond to content changes by overriding `contentsDidChange`
- More customization of the text fields by overriding `createTextFieldForCell`.
- Add more section to the table and customize cells by overriding `numberOfSectionsInTableView` and `cellForRowAtIndexPath`.