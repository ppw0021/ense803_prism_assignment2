mdp

module DrinkSelectionInterface
	//0 = none. 1 = Kiwi-Cola. 2 = Bolt Energy. 3 = Clear Water
	drink_selection: [0..3] init 0;

	//Transitions for selecting drinks
	[select_kiwi] drink_selection=0 -> (drink_selection'=1);
	[select_bolt] drink_selection=0 -> (drink_selection'=2);
	[select_water] drink_selection=0 -> (drink_selection'=3);

	//Allow changing selection
	[change_selection] drink_selection>0 -> (drink_selection'=0);
endmodule

module EFPOSPayment
	//0 = Not paid. 1 = Paid. 2 = Incorrect Pin
	payment_status: [0..2] init 0;
    
	//Transitions for payment
	[enter_pin_correct] payment_status=0 -> (payment_status'=1);
	[enter_pin_incorrect] payment_status=0 -> (payment_status'=2);

	//Reset after incorrect pin
	[reset_transaction] payment_status=2 -> (payment_status'=0);
endmodule

module DrinkDispenser
	//Drink levels, for this example we start with 5 each
	kiwi_stock: [0..5] init 5;
	bolt_stock: [0..5] init 5;
	water_stock: [0..5] init 5;

	//Errors, here 0 is false, and 1 is true
	error: [0..1] init 0;
	maintenance: [0..1] init 0;

	//Dispense transistions
	//Dispense kiwi if the payment status is 1, drink_selection is 1, and kiwi_stock is greater than 0
	[dispense_kiwi] payment_status=1 & drink_selection=1 & kiwi_stock>0 -> (kiwi_stock'=kiwi_stock-1);

	//Dispense bolt if the payment status is 1, drink_selection is 2, and bolt_stock is greater than 0
	[dispense_bolt] payment_status=1 & drink_selection=2 & bolt_stock>0 -> (bolt_stock'=bolt_stock-1);

	//Dispense water if the payment status is 1, drink_selection is 3, and water_stock is greater than 0
	[dispense_water] payment_status=1 & drink_selection=3 & water_stock>0 -> (water_stock'=water_stock-1);

	//Error transistion
	[error_event] error=1 -> (maintenance'=1);

	//Maintenance if any drink runs out
	[check_stock] (kiwi_stock=0 | bolt_stock=0 | water_stock=0) -> (maintenance'=1);
endmodule

