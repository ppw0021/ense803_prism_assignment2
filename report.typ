#set page("a4")

#set page(
  header: [
    _ENSE803 Design Team Project_
    #h(1fr)
    Vending Machine Controller Verification
  ],
)

#set page(
  footer: context [
    _Declan Ross, Anson Huang, Mahiir Hussain Shaik_
    #h(1fr)
    #counter(page).display(
      "1 of 1",
      both: true,
    )
  ],
)

= Design Team Project - Vending Machine Controller Verification 
== ENSE803 - Formal Specification and Design
=== Declan Ross (20108351) 
=== Anson Huang (20120333)
=== Mahiir Hussain Shaik (********)

#pagebreak()

= PRISM Model
Here is our PRISM model for the project, it was created and initially written in VSCode, then tested in the PRISM model checker. 
```
PRISM MODEL CODE GOES HERE
```
//#pagebreak()
= Design Decisions
Our design decisions for this model are as follows:
1. The model is modular design, with the Components being split into logical Modules: _DrinkSelectionInterface, EFPOSPayment,_ and _DrinkDispenser_. This makes understanding the model easier, as each module has a specific purpose.
2. Clear and consise variable names are used throughout the model, such as _drink_selection,_ _payment_status_ etc. This makes it easier to understand the model and its purpose.
3. The model uses good transitions, ensuring that transistions only occur when the correct conditions are met. For example, the _dispense_ transition only occurs when the _payment_status_ is _paid_ and the _drink_selection_ is not empty.

//#pagebreak()
= Scenarios
Here are our scenarios.
== Scenario 1
_Customer selects Clear Water and pays via EFPOS, with correct pin._\
Simulation trace output for each scenario with discussion

== Scenario 2
_Customer selects Kiwi-Cola and pays via EFPOS, with incorrect pin._\
Simulation trace output for each scenario with discussion

== Scenario 3
_Customer selects a drink but an error occurs._\
Simulation trace output for each scenario with discussion

== Scenario 4
_Customer selects a Clear Water but there are no drinks of this kind available._\
Simulation trace output for each scenario with discussion

== Scenario 5
_Customer purchases Bolt Energy Drink and then purchases Clear Water._\
Simulation trace output for each scenario with discussion

= Temporal Logic Formulae
Specify Temporal logic Formulae to determine the validity of the following properties
1. Once in, the vending machine never leaves maintenance mode
2. If an error occurs, then maintenance mode occurs in the next state
3. A customer may not select an unavailable drink _AG (soda empty -> AF soda not selected)_
4. When a customer pays for a drink, it is dispensed _AG (pay -> AF dispense)_