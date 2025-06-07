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

= Design Team Project \ Vending Machine Controller Verification 
== ENSE803 - Formal Specification and Design
=== Declan Ross (20108351) 
=== Anson Huang (20120333)
=== Mahiir Hussain Shaik (21154502)

#pagebreak()

== PRISM Model
Here is our PRISM model for the project, it was created and initially written in VSCode, then tested in the PRISM model checker. 
```js
mdp

//Constants for drink types and stock
const int none = 0;
const int kiwi = 1;
const int bolt = 2;
const int water = 3;
const int max_stock = 3;

module DrinkSelection
    state: [0..3] init none; //0=none, 1=Kiwi-Cola, 2=Bolt Energy, 3=Clear Water

    //Select drink if stock available and not in maintenance mode
    [select_kiwi] state=none & kiwi_stock>0 & !maintenance -> (state'=kiwi);
    [select_bolt] state=none & bolt_stock>0 & !maintenance -> (state'=bolt);
    [select_water] state=none & water_stock>0 & !maintenance -> (state'=water);

    //Change selection before payment
    [change_selection] state>none & !maintenance & !pay -> (state'=none);
    
    //Synchronize with payment and reset after dispensing
    [pay] state>none & pay & !maintenance -> (state'=none);
    
    //Reset on incorrect PIN
    [reset] state>none & payment_error & !maintenance -> (state'=none);
endmodule

module EFPOSPayment
    pay: bool init false; //True when payment is successful
    payment_error: bool init false; //True when incorrect PIN entered
    
    //Start payment after selection
    [start_payment] state>none & !pay & !payment_error & !maintenance -> (pay'=true);
    
    //Incorrect PIN
    [wrong_pin] state>none & !pay & !payment_error & !maintenance -> (payment_error'=true);
    
    //Reset after incorrect PIN
    [reset] payment_error & !maintenance -> (payment_error'=false) & (pay'=false);
    
    //Reset after dispensing
    [dispense] pay & !maintenance -> (pay'=false);
endmodule

module Dispenser
    kiwi_stock: [0..max_stock] init max_stock;
    bolt_stock: [0..max_stock] init max_stock;
    water_stock: [0..max_stock] init max_stock;
    error: bool init false;
    maintenance: bool init false;
    dispense: bool init false;
    
    //Dispense drink if paid and stock available
    [dispense] pay & state=kiwi & kiwi_stock>0 & !maintenance -> (kiwi_stock'=kiwi_stock-1) & (dispense'=true);
    [dispense] pay & state=bolt & bolt_stock>0 & !maintenance -> (bolt_stock'=bolt_stock-1) & (dispense'=true);
    [dispense] pay & state=water & water_stock>0 & !maintenance -> (water_stock'=water_stock-1) & (dispense'=true);
    
    //Reset dispense flag
    [reset_dispense] dispense & !maintenance -> (dispense'=false);
    
    //Simulate error event
    [error_event] !error & !maintenance -> 0.99:(error'=false) + 0.01:(error'=true);
    
	//Error event
	[error_event] error & !maintenance -> (maintenance'=true);
    
    //Maintenance mode when all drinks are empty
    [check_stock] kiwi_stock=0 & bolt_stock=0 & water_stock=0 & !maintenance -> (maintenance'=true);
    
    //Stay in maintenance mode
    [] maintenance -> (maintenance'=true);
endmodule
```
//#pagebreak()
== Design Decisions
Our design decisions for this model are as follows:
1. The model is modular design, with the Components being split into logical Modules: _DrinkSelectionInterface, EFPOSPayment,_ and _Dispenser_. This makes understanding the model easier, as each module has a specific purpose.
2. Clear and consise variable names are used throughout the model, such as _drink_selection,_ _payment_status_ etc. This makes it easier to understand the model and its purpose.
3. The model uses good transitions, ensuring that transistions only occur when the correct conditions are met. For example, the _dispense_ transition only occurs when the _payment_status_ is _paid_ and the _drink_selection_ is not empty.

//#pagebreak()
== Scenarios
Here are our scenarios.
=== Scenario 1
_Customer selects Clear Water and pays via EFPOS, with correct pin._\
Simulation trace output for each scenario with discussion

=== Scenario 2
_Customer selects Kiwi-Cola and pays via EFPOS, with incorrect pin._\
Simulation trace output for each scenario with discussion

=== Scenario 3
_Customer selects a drink but an error occurs._\
Simulation trace output for each scenario with discussion

=== Scenario 4
_Customer selects a Clear Water but there are no drinks of this kind available._\
Simulation trace output for each scenario with discussion

=== Scenario 5
_Customer purchases Bolt Energy Drink and then purchases Clear Water._\
Simulation trace output for each scenario with discussion

== Temporal Logic Formulae
1. Once in, the vending machine never leaves maintenance mode
2. If an error occurs, then maintenance mode occurs in the next state
3. A customer may not select an unavailable drink _AG (soda empty -> AF soda not selected)_
4. When a customer pays for a drink, it is dispensed _AG (pay -> AF dispense)_