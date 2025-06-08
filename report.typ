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
mdp

// Constants for drink types and stock
const int none = 0;
const int kiwi = 1;
const int bolt = 2;
const int water = 3;
const int max_stock = 3; //Minimum 3 per assignment

module DrinkSelection
    state: [0..3] init none; //0=none, 1=Kiwi-Cola, 2=Bolt Energy, 3=Clear Water

    //Select any drink directly from the menu only if it's in stock
    [select_kiwi] state=none & kiwi_stock>0 & !maintenance & !pay & !dispense & !main & !error -> (state'=kiwi);
    [select_bolt] state=none & bolt_stock>0 & !maintenance & !pay & !dispense & !main & !error -> (state'=bolt);
    [select_water] state=none & water_stock>0 & !maintenance & !pay & !dispense & !main & !error -> (state'=water);

    //Change selection if selected drink is out of stock
    [change_selection] state=kiwi & kiwi_stock=0 & !maintenance & !pay & !dispense & !main & !error -> (state'=none);
    [change_selection] state=bolt & bolt_stock=0 & !maintenance & !pay & !dispense & !main & !error -> (state'=none);
    [change_selection] state=water & water_stock=0 & !maintenance & !pay & !dispense & !main & !error -> (state'=none);

    //Synchronize with payment, incorrect PIN, or error
    [change_selection] state>none & !maintenance & !main & !error -> (state'=none);
    [wrong_pin] state>none & !maintenance & !main & !error -> (state'=none);
    [error] state>none & !maintenance & !main & !error -> (state'=none);
endmodule

module PaymentDispenser
    pay: bool init false; //True when payment is initiated
    dispense: bool init false; //True when dispensing
    kiwi_stock: [0..max_stock] init max_stock;
    bolt_stock: [0..max_stock] init max_stock;
    water_stock: [0..max_stock] init max_stock;
    maintenance: bool init false;
```
#pagebreak()
```js
//Process payment (correct PIN, sets dispense=true, reduces stock if available)
    [pay_dispense_kiwi] state=kiwi & !maintenance & !dispense & !main & !error & kiwi_stock>0 -> (pay'=false) & (dispense'=true) & (kiwi_stock'=kiwi_stock-1);
    [pay_dispense_bolt] state=bolt & !maintenance & !dispense & !main & !error & bolt_stock>0 -> (pay'=false) & (dispense'=true) & (bolt_stock'=bolt_stock-1);
    [pay_dispense_water] state=water & !maintenance & !dispense & !main & !error & water_stock>0 -> (pay'=false) & (dispense'=true) & (water_stock'=water_stock-1);
    [kiwi_out_of_stock] state=kiwi & !maintenance & !dispense & !main & !error & kiwi_stock=0 -> (pay'=false) & (dispense'=true);
    [bolt_out_of_stock] state=bolt & !maintenance & !dispense & !main & !error & bolt_stock=0 -> (pay'=false) & (dispense'=true);
    [water_out_of_stock] state=water & !maintenance & !dispense & !main & !error & water_stock=0 -> (pay'=false) & (dispense'=true);

    //Reset dispense flag after payment
    [] dispense=true & !maintenance & !main & !error -> (dispense'=false);

    //Incorrect PIN
    [wrong_pin] state>none & !pay & !dispense & !main & !error -> true;

    //Maintenance mode when all drinks are empty
    [check_stock] state=none & kiwi_stock=0 & bolt_stock=0 & water_stock=0 & !maintenance & !main & !error -> (maintenance'=true);

    //Stay in maintenance mode
    [] maintenance -> (maintenance'=true);

    //Synchronize maintenance with error
    [error] state>none & !pay & !dispense & !main & !error -> (maintenance'=true);
endmodule

module Error
    main : bool init false;
    error : bool init false;
    [error] !main & !error -> (error'=true);
    [main] error -> (main'=true) & (error'=false);
endmodule
```
//#pagebreak()
==== Design Decisions
1. _Modular Structure._ The model is designed modularly, with components logically divided into separate modules: _DrinkSelection,_ _Payment Dispenser,_ and _Error._ This separation of concerns improves readability and maintainability, as each module has a well-defined purpose.

2. _Clear and Concise Variable Naming._ Descriptive and consistent variable names such as _state_, _kiwi_stock_, and _pay_ are used throughout the model. This improves code clarity and helps users understand the model's behavior.

3. _Well-Defined Transitions._ Transitions are defined with guard conditions to ensure that actions only occur under valid circumstances. For instance, the dispense transition only triggers when payment has been successfully made and a valid drink selection has been made.

4. _Intentional Error_. You can intentionally cause an error by selecting error after selecting a drink. This is a deliberate design choice to demonstrate the model's error handling capabilities. The error transition leads to a maintenance mode.

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
  caption: "Error occurs in the next state, simulator tab"
)
#pagebreak()
3. A customer may not select an unavailable drink _AG (soda empty -> AF soda not selected):_
#figure(
  image("Formulae/formula3a.png", width: 90%),
  caption: "Unavailable Drink Selection"
)
#figure(
  image("Formulae/formula3b.png", width: 90%),
  caption: "Unavailable Drink Selection, only able to select available drinks, simulator tab"
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