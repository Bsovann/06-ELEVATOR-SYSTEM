`timescale 1ns / 1ns

module tb_elevator ();
  reg  clk;
  reg  rst;
  reg  floor_button1;
  reg  floor_button2;
  reg  floor_button3;
  reg  elevator_arrived;
  wire floor1_led;
  wire floor2_led;
  wire floor3_led;
  wire elevator_direction;
  wire door_open;

  // Instantiate the elevator module
  elevator elevator_instance (
      .clk(clk),
      .rst(rst),
      .floor_button1(floor_button1),
      .floor_button2(floor_button2),
      .floor_button3(floor_button3),
      .elevator_arrived(elevator_arrived),
      .floor1_led(floor1_led),
      .floor2_led(floor2_led),
      .floor3_led(floor3_led),
      .elevator_direction(elevator_direction),
      .door_open(door_open)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Stimulus generation
  initial begin
    // Initialize signals
    clk = 1;
    rst = 0;
    floor_button1 = 0;
    floor_button2 = 0;
    floor_button3 = 0;
    elevator_arrived = 0;

    // Apply reset
    rst = 1;
    #10 rst = 0;

    // Request for floor 2
    #10 @(posedge clk) floor_button2 = 1;
    @(posedge clk) floor_button2 = 0;

    // Elevator starts moving
    #25 elevator_arrived = 1;

    // Request for floor 3
    @(posedge clk) floor_button3 = 1;
    @(posedge clk) floor_button3 = 0;

    // Elevator keeps moving
    #25 elevator_arrived = 1;

    // Request for floor 1
    @(posedge clk) floor_button1 = 1;
    @(posedge clk) floor_button1 = 0;

    // Elevator keeps moving
    #75 elevator_arrived = 1;

    // Run for a while and then finish
    #230 $finish;
  end


  // Display information
  always @(posedge clk) begin
    if (floor_button1) $display("Floor request: 1");
    if (floor_button2) $display("Floor request: 2");
    if (floor_button3) $display("Floor request: 3");

    if (floor1_led) $display("Current floor: 1");
    if (floor2_led) $display("Current floor: 2");
    if (floor3_led) $display("Current floor: 3");

    case (elevator_direction)
      2'b00: begin
        if (door_open) $display("Elevator state: Stationary, Door Open");
        else $display("Elevator state: Stationary, Door Closed");
      end
      2'b01: $display("Elevator direction: Up");
      2'b10: $display("Elevator direction: Down");
    endcase

    $display("-------------------------------------------------------------");
  end

endmodule
