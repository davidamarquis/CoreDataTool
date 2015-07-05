# CoreDataModeller

Xcode projects requiring local storage often use [Core Data](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdTechnologyOverview.html#//apple_ref/doc/uid/TP40009296-SW1). The goal of CoreDataModeller is to provide a graphical modelling tool similar to the one provided in an .xcdatamodeld file in Xcode and to automatically generate code for an equivalent Core Data that can be used in an Xcode project. 

Using this tool a user can set up data models on their own device before they begin a new project and continue to make changes to the data model throughout the project lifecycle. 

Before using this tool the user should know the [basic terms](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdMOM.html#//apple_ref/doc/uid/TP40002328-SW1) of managed object models. Each model change is done in two steps: 
First, the user creates entities and assigns them names, attributes and relationships. Each attribute can be assigned a name and a type. Each relationship can be assigned a name, a name of the inverse of the relationship and a destination. 
Second, CoreDataModeller generates ObjectiveC code for the application delegate containing code to set up an empty data store and a method that populates this data store with the entities and their properties that the user has defined on the device. 

## Modelling
Similarly to a .xcdatamodeld file in Xcode, modelling is done in two views. When the user has launchs the application they are presented with a graphical representation of the entities and the relationships between them. At the bottom of the screen they can select between 3 different modes: Move, Entity, and Relationship: 
In Move mode the user can pan the model and zoom in and out. This mode allows the user to build larger data models than would otherwise be possible. 
In Entity mode new entities can be created by tapping on the plus icon on the bottom right hand side and moving the finger to the desired location. Existing entities can be deleted by tapping on them and dragging to the minus icon.
In Relationship mode new relationships can be created by tapping on an entity and dragging to the desired location. Existing relationships can be deleted by dragging them to the minus icon. 

In all three modes tapping on an entity brings up a view of the contents of that entity. Here the user can add attributes and relationships or customize relationships that have been created.

## Future Work
Add ability to set deletion rules to relationships. Add ability to make properties optional. Add saving multiple CoreDataModeller projects on the device.
