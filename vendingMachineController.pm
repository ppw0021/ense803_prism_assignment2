mdp

//Constants for drink types and stock
const int none = 0;
const int kiwi = 1;
const int bolt = 2;
const int water = 3;
const int max_stock = 3;

const int drinkSelectionModule = 0;
const int efposPaymentModule = 1;
const int dispenserModule = 2;

const int readyToDispense = 0;
const int dispensing = 1;
const int doneDispensing = 2;

module DrinkSelection
    moduleState: [0..2] init drinkSelectionModule;
    state: [0..3] init none; // 0=none, 1=Kiwi-Cola, 2=Bolt Energy, 3=Clear Water
    selected_state: [0..3] init none;
    // Select drink if stock available and not in maintenance mode
    [select_kiwi] moduleState=drinkSelectionModule & state=none & kiwi_stock>0 & !maintenance -> (state'=kiwi);
    [select_bolt] moduleState=drinkSelectionModule & state=none & bolt_stock>0 & !maintenance -> (state'=bolt);
    [select_water] moduleState=drinkSelectionModule & state=none & water_stock>0 & !maintenance -> (state'=water);

    
    // Change selection before payment
    [change_selection] moduleState=drinkSelectionModule & state>none & !maintenance & !pay -> (state'=none);

    // Synchronize with payment and reset after dispensing
    [pay] moduleState=drinkSelectionModule & state>none & pay=false & !maintenance -> (selected_state'=state) & (state'=none) & (moduleState'=efposPaymentModule);

    // Reset on incorrect PIN
    [reset] moduleState=drinkSelectionModule & state>none & payment_error & !maintenance -> (state'=none);

    //Transisiton to dispenser
    [transistion_to_dispense] moduleState=efposPaymentModule & pay -> (moduleState'=dispenserModule);

    //Transistion back to start
    [transistion_to_start] moduleState=doneDispensing & pay & dispense=doneDispensing -> (moduleState'=drinkSelectionModule) & (state'=none) & (selected_state'=none);
endmodule

module EFPOSPayment
    pay: bool init false; //True when payment is successful
    payment_error: bool init false; //True when incorrect PIN entered
    incorrect_pin: bool init false; //Manually set false pin
    
    //Start payment after selection
    [start_payment] moduleState=efposPaymentModule & selected_state>none & pay=false & payment_error=false & maintenance=false -> (pay'=true);
    
    //Incorrect PIN
    [wrong_pin] moduleState=efposPaymentModule & state>none & pay=false & incorrect_pin & payment_error=false & maintenance=false -> (payment_error'=true);
    
    //Reset after incorrect PIN
    [reset] moduleState=efposPaymentModule & payment_error & maintenance=false -> (payment_error'=false) & (pay'=false);
    
    //Reset after dispensing
    [reset_pay] moduleState=drinkSelectionModule & !maintenance & dispense=readyToDispense & pay -> (pay'=false);
endmodule

module Dispenser
    kiwi_stock: [0..max_stock] init max_stock;
    bolt_stock: [0..max_stock] init max_stock;
    water_stock: [0..max_stock] init max_stock;
    maintenance: bool init false;
    dispense: [0..2] init readyToDispense;
    
    [reset_dispense] moduleState=drinkSelectionModule & dispense=doneDispensing -> (dispense'=readyToDispense);

    //Dispense drink if paid and stock available
    [dispense_kiwi] moduleState=dispenserModule & pay & selected_state=kiwi & kiwi_stock>0 & dispense=readyToDispense & !maintenance -> (kiwi_stock'=kiwi_stock-1) & (dispense'=dispensing);
    [dispense_bolt] moduleState=dispenserModule & pay & selected_state=bolt & bolt_stock>0 & dispense=readyToDispense & !maintenance -> (bolt_stock'=bolt_stock-1) & (dispense'=dispensing);
    [dispense_water] moduleState=dispenserModule & pay & selected_state=water & water_stock>0 & dispense=readyToDispense & !maintenance -> (water_stock'=water_stock-1) & (dispense'=dispensing);
    
    //Reset dispense flag
    //[reset_dispense] dispense & !maintenance -> (dispense'=false);
    [set_dispense_to_done] dispense=dispensing -> (dispense'=doneDispensing);
    
    //Maintenance mode when all drinks are empty
    [check_stock] kiwi_stock=0 & bolt_stock=0 & water_stock=0 & !maintenance -> (maintenance'=true);
    
    //Stay in maintenance mode
    [] maintenance -> (maintenance'=true);
endmodule