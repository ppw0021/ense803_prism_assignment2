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


#show heading.where(level:1):set text(
  size: 36pt
)

#show heading.where(level:2):set text(
  size: 20pt
)

#show heading.where(level:3):set text(
  size: 16pt
)

#show figure.caption: emph

= Design Team Project \ Vending Machine Controller Verification 
== ENSE803 - Formal Specification and Design
Declan Ross (20108351) \
Anson Huang (20120333)\
Mahiir Hussain Shaik (21154501)\

#pagebreak()

== PRISM Model
Here is our PRISM model for the project, it was created and initially written in VSCode, then tested in the PRISM model checker. 
```js

```
#pagebreak()
```js

```
//#pagebreak()
==== Design Decisions
1. _Modular Structure._ The model is designed modularly, with components logically divided into separate modules: _DrinkSelection,_ _EFPOSPayment,_ and _Dispenser._ This separation of concerns improves readability and maintainability, as each module has a well-defined purpose.

2. _Clear and Concise Variable Naming._ Descriptive and consistent variable names such as _state_, _kiwi_stock_, and _pay_ are used throughout the model. This improves code clarity and helps users understand the model's behavior at a glance.

3. _Well-Defined Transitions._ Transitions are defined with precise guard conditions to ensure that actions only occur under valid circumstances. For instance, the dispense transition only triggers when payment has been successfully made and a valid drink selection has been made.

#pagebreak()
== Scenarios
Here are our scenarios.
==== Scenario 1
_Customer selects Clear Water and pays via EFPOS, with correct pin._\
#figure(
  image("Scenarios/scenario1.png", width: 60%),
  caption: "Simulation trace output: Customer selects Clear Water and pays via EFPOS with correct pin"
)
In this scenario, the customer successfully selects Clear Water and pays via EFPOS with the correct pin. The simulation trace shows that the drink is dispensed correctly, and the stock of Clear Water is reduced by one. The system remains in a normal operational state without entering maintenance mode.

==== Scenario 2
#figure(
  image("Scenarios/scenario2.png", width: 60%),
  caption: "Simulation trace output: Customer selects Kiwi-Cola and pays via EFPOS with incorrect pin"
)
In this scenario, the customer attempts to select Kiwi-Cola and pay via EFPOS but enters an incorrect pin. The simulation trace shows that the payment fails, and the system resets the payment status. The customer can then reattempt the selection or payment without entering maintenance mode.

==== Scenario 3
#figure(
  image("Scenarios/scenario3.png", width: 60%),
  caption: "Simulation trace output: Customer selects a drink but an error occurs"
)
In this scenario, the customer selects a drink, but an error occurs during the process. The simulation trace shows that the system enters maintenance mode due to the error. The customer cannot complete the transaction until the error is resolved, ensuring that the system remains in a safe state.

==== Scenario 4
#figure(
  image("Scenarios/scenario4.png", width: 60%),
  caption: "Simulation trace output: Customer selects Clear Water but no drinks available"
)
_Customer selects a Clear Water but there are no drinks of this kind available._\
In this scenario, the customer attempts to select Clear Water, but there are no drinks available. The simulation trace shows that the system does not allow the selection of an unavailable drink, and the customer is prompted to make a different selection. This ensures that the vending machine does not dispense an empty or unavailable drink.
#pagebreak()
==== Scenario 5
#figure(
  image("Scenarios/scenario5.png", width: 60%),
  caption: "Simulation trace output: Customer purchases Bolt Energy Drink and then purchases Clear Water"
)
Simulation trace output for each scenario with discussion
In this scenario, the customer successfully purchases a Bolt Energy Drink and then proceeds to purchase Clear Water. The simulation trace shows that the system correctly updates the stock levels for both drinks and dispenses them as expected. The system remains in a normal operational state without entering maintenance mode, demonstrating its ability to handle multiple transactions sequentially.
== Temporal Logic Formulae
Here is our list of Formulae:
#figure(
  image("Formulae/main.png", width: 80%),
  caption: "Temporal Logic Formulae for Vending Machine Controller Verification"
)
1. Once in, the vending machine never leaves maintenance mode:
#figure(
  image("Formulae/formula1a.png", width: 30%),
  caption: "Maintenance Mode"
)
#figure(
  image("Formulae/formula1b.png", width: 90%),
  caption: "Maintenance mode, simulator tab"
)
2. If an error occurs, then maintenance mode occurs in the next state:
#figure(
  image("Formulae/formula2a.png", width: 30%),
  caption: "Error Handling"
)
#figure(
  image("Formulae/formula2b.png", width: 90%),
  caption: "Error Handling mode, simulator tab"
)
3. A customer may not select an unavailable drink _AG (soda empty -> AF soda not selected):_
#figure(
  image("Formulae/formula3a.png", width: 90%),
  caption: "Unavailable Drink Selection"
)
#figure(
  image("Formulae/formula3b.png", width: 90%),
  caption: "Unavailable Drink Selection, simulator tab"
)
4. When a customer pays for a drink, it is dispensed _AG (pay -> AF dispense):_
#figure(
  image("Formulae/formula4a.png", width: 30%),
  caption: "Drink Dispensing"
)
#figure(
  image("Formulae/formula4b.png", width: 90%),
  caption: "Drink Dispensing, simulator tab"
)