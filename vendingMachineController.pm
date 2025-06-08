mdp

//Constants for drink types and stock
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
    [pay] state>none & !maintenance & !main & !error -> (state'=none);
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

    //Process payment (correct PIN, sets dispense=true, reduces stock if available)
    [pay] state=kiwi & !maintenance & !dispense & !main & !error & kiwi_stock>0 -> (pay'=false) & (dispense'=true) & (kiwi_stock'=kiwi_stock-1);
    [pay] state=bolt & !maintenance & !dispense & !main & !error & bolt_stock>0 -> (pay'=false) & (dispense'=true) & (bolt_stock'=bolt_stock-1);
    [pay] state=water & !maintenance & !dispense & !main & !error & water_stock>0 -> (pay'=false) & (dispense'=true) & (water_stock'=water_stock-1);
    [pay] state=kiwi & !maintenance & !dispense & !main & !error & kiwi_stock=0 -> (pay'=false) & (dispense'=true);
    [pay] state=bolt & !maintenance & !dispense & !main & !error & bolt_stock=0 -> (pay'=false) & (dispense'=true);
    [pay] state=water & !maintenance & !dispense & !main & !error & water_stock=0 -> (pay'=false) & (dispense'=true);

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

module error
    main : bool init false;
    error : bool init false;
    [error] !main & !error -> (error'=true);
    [main] error -> (main'=true) & (error'=false);
endmodule