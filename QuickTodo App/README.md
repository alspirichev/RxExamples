#  QuickTodo

1. **Bindable view controllers**

You need to connect, or bind, the view controllers to their associated view model. One way to do this is have your controllers adopt a specific protocol: **BindableType**.
Each *view controller* conforming to the BindableType protocol will declare a *viewModel* variable and provide a bindViewModel() function to be called once the viewModel variable is assigned. This function will connect UI elements to observables and actions in the *view model*.

2. **Task model**

There are two details you need to be aware of that are specific to objects coming from a Realm database:
* Objects can’t cross threads. If you need an object in a different thread, either requery or use a Realm ThreadSafeReference.
* Objects are auto-updating. If you make a change to the database, it immediately reflects in the properties of any live object queried from the database. This has its uses as you’ll see further down.
* As a consequence, deleting an object invalidates all existing copies. If you access any property of a queried object that is deleted, you’ll get an exception.

3. **Tasks service**

The tasks service is responsible for creating, updating and fetching task items from the store. As a responsible developer, you’ll define your service public interface using a protocol then write the runtime implementation and a mock implementation for tests.

The most important detail is that the service exposes all data as observable sequences. Even the functions which create, delete, update and toggle tasks return an observable you can subscribe to.

4. **Scenes**

(Refers to a screen managed by a view controller. It can be a regular screen, or a modal dialog. It comprises a view controller and a view model.)

Rules for scenes are:
* The *view model* handles the business logic. This extends to kicking off the transition to another “scene”.
* View models know nothing about the actual view controller and views used to represent the scene.
* *View controllers* shouldn’t initiate the transition to another scene; this is the domain of the business logic running in the view model.

5. **Coordinating scenes**

One of the most puzzling questions when developing an architecture around MVVM is: “*How does the application transition from scene to scene?*”. There are many answers to this question, as every architecture has a different take on it. Some do it from the **view controller**, because of the need to instantiate another view controller; while some do it using a **router**, which is a special object thats connects view models.

6. **Binding the tasks list with RxDataSources**

Instead of passing an *array* of items to the table or collection view, you pass an *array of section* models. The section model defines both what goes in the section header (if any), and the data model of each item.



