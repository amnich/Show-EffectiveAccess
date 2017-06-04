# Show-EffectiveAccess

Show GUI with effective access rights of a user on directories on given path as a tree.

Module [PowerShellAccessControl](https://github.com/PowerShellOrg/PowerShellAccessControl) is required.
	
	
  
  So basically you will see the directory structure as the user sees it and have all permissions listed.
  ![example](https://github.com/amnich/Show-EffectiveAccess/blob/master/example.png)
  
  On click on a directory in the tree view the permission's are loaded and subdirectories checked and expanded.
  You must have full access to a path for best results, because the directories are loaded with your credentials and then checked for user access.
  
  Form based on [this post](https://blogs.technet.microsoft.com/heyscriptingguy/2010/06/15/hey-scripting-guy-how-can-i-use-the-windows-forms-treeview-control/) by Ravikanth  

# Version 1.1
  Added switch ShowAll to also show directories where user has no access. Marked red in tree.

  Added show ACL on restriced folders.

