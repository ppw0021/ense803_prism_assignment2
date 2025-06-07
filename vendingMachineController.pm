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