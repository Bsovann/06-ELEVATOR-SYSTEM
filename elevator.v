module elevator (
    input  clk,
    rst,
    floor_button1,
    floor_button2,
    floor_button3,
    elevator_arrived,
    output floor1_led,
    floor2_led,
    floor3_led,
    elevator_direction,
    door_open
);

  // Define states
  parameter IDLE = 2'd0;
  parameter GOING_UP = 2'd1;
  parameter GOING_DOWN = 2'd2;
  parameter WAITING = 2'd3;
  parameter CHECK_NEXT_REQUEST = 2'd4;

  // Define constants
  parameter T_WAIT = 4;  // Time to wait at a floor (in clock cycles)
  parameter T_DOOR = 2;  // Time to open or close the door (in clock cycles)

  // Define registers
  reg [1:0] current_state;
  reg [1:0] next_state;
  reg [1:0] current_floor;
  reg [1:0] next_floor;
  reg [2:0] floor_requests;
  reg [1:0] direction;
  reg [3:0] wait_counter;  // Increase bit width
  reg [3:0] door_counter;  // Increase bit width
  reg door_open;

  // Output assignments
  assign floor1_led = (current_floor == 2'b00);
  assign floor2_led = (current_floor == 2'b01);
  assign floor3_led = (current_floor == 2'b10);
  assign elevator_direction = direction;

  // State transition and output logic
  always @(posedge clk) begin
    if (rst) begin
      current_state <= IDLE;
      current_floor <= 2'b00;
      next_floor <= 2'b00;
      floor_requests <= 3'b000;
      direction <= 2'b00;
      wait_counter <= 4'b0000;
      door_counter <= 4'b0000;
      door_open <= 1'b0;
    end else begin
      current_state <= next_state;
      current_floor <= next_floor;

      // Update floor_requests in all states
      floor_requests <= floor_requests | (floor_button1 << 0) | (floor_button2 << 1) | (floor_button3 << 2);

      case (current_state)
        IDLE: begin
          if (floor_requests != 3'b000) begin
            if ((floor_requests & (3'b111 << current_floor)) != 3'b000) begin
              next_state = GOING_UP;
              next_floor = current_floor + 1;
              direction  = 2'b01;
            end else begin
              next_state = GOING_DOWN;
              next_floor = current_floor - 1;
              direction  = 2'b10;
            end
            wait_counter <= T_WAIT;
          end else begin
            next_state = IDLE;
            next_floor = current_floor;
            direction  = 2'b00;
            wait_counter <= 4'b0000;
          end
        end
        GOING_UP: begin
          if (elevator_arrived) begin
            if ((floor_requests & (1 << current_floor)) != 0) begin
              next_state = WAITING;
              next_floor = current_floor;
              direction  = 2'b00;
              wait_counter <= T_WAIT;
              door_open <= 1'b1;
              door_counter <= T_DOOR;
            end else begin
              next_state = GOING_UP;
              next_floor = current_floor + 1;
              direction  = 2'b01;
              wait_counter <= 4'b0000;
            end
          end else begin
            next_state = GOING_UP;
            next_floor = current_floor;
            direction  = 2'b01;
            wait_counter <= 4'b0000;
          end
        end
        GOING_DOWN: begin
          if (elevator_arrived) begin
            if ((floor_requests & (1 << current_floor)) != 0) begin
              next_state = WAITING;
              next_floor = current_floor;
              direction  = 2'b00;
              wait_counter <= T_WAIT;
              door_open <= 1'b1;
              door_counter <= T_DOOR;
            end else begin
              next_state = GOING_DOWN;
              next_floor = current_floor - 1;
              direction  = 2'b10;
              wait_counter <= 4'b0000;
            end
          end else begin
            next_state = GOING_DOWN;
            next_floor = current_floor;
            direction  = 2'b10;
            wait_counter <= 4'b0000;
          end
        end
        WAITING: begin
          if (door_counter > 4'b0000) begin
            door_counter <= door_counter - 4'b0001;
            door_open <= 1'b1;
            next_state <= WAITING;
          end else if (wait_counter > 4'b0000) begin
            wait_counter <= wait_counter - 4'b0001;
            door_open <= 1'b1;
          end else begin
            floor_requests <= floor_requests & ~(1 << current_floor);
            next_state <= CHECK_NEXT_REQUEST;
            door_open <= 1'b0;
          end
        end
        CHECK_NEXT_REQUEST: begin
          if (floor_requests != 3'b000) begin
            if (floor_requests > current_floor) begin
              next_state = GOING_UP;
              next_floor = current_floor + 1;
              direction  = 2'b01;
            end else begin
              next_state = GOING_DOWN;
              next_floor = current_floor - 1;
              direction  = 2'b10;
            end
          end else begin
            next_state = IDLE;
            next_floor = current_floor;
            direction  = 2'b00;
          end
        end
      endcase
    end
  end
endmodule
