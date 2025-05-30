`timescale 1ns/1ps
`include "multiplication.sv"
module fp_mult_tb;

logic clk, rst;
logic [31:0] a, b;
logic [2:0] rnd;
logic [31:0] z;
logic [7:0] status;

fp_mult_top dut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .rnd(rnd),
    .z(z),
    .status(status)
);

bind dut test_status_bits dutbound (clk, status);

bind dut test_status_z_combinations dutbound_z (clk, status, z ,a ,b);


typedef enum logic[3:0] {
    neg_SNAN = 4'b0000,
    pos_SNAN = 4'b0001,
    neg_QNAN = 4'b0010,
    pos_QNAN = 4'b0011,
    neg_INF = 4'b0100,
    pos_INF = 4'b0101,
    neg_normal = 4'b0110,
    pos_normal = 4'b0111,
    neg_denormal = 4'b1000,
    pos_denormal = 4'b1001,
    neg_zero = 4'b1010,
    pos_zero = 4'b1011
} corner_case_t;

function logic [31:0] corner_case_to_bits(corner_case_t ccase);
    case (ccase)
        neg_SNAN:  return 32'hFFC00001; 
        pos_SNAN:  return 32'h7FC00001; 
        neg_QNAN:  return 32'hFFE00000; 
        pos_QNAN:  return 32'h7FE00000; 
        neg_INF:   return 32'hFF800000; 
        pos_INF:   return 32'h7F800000; 
        neg_normal: return 32'hBF800000; 
        pos_normal: return 32'h3F800000; 
        neg_denormal: return 32'h80000001; 
        pos_denormal: return 32'h00000001; 
        neg_zero:  return 32'h80000000; 
        pos_zero:  return 32'h00000000; 
        default:   return 32'h00000000;
    endcase
endfunction

function string corner_case_to_string(corner_case_t ccase);
    case (ccase)
        neg_SNAN: return "neg_SNAN";
        pos_SNAN: return "pos_SNAN";
        neg_QNAN: return "neg_QNAN";
        pos_QNAN: return "pos_QNAN";
        neg_INF: return "neg_INF";
        pos_INF: return "pos_INF";
        neg_normal: return "neg_normal";
        pos_normal: return "pos_normal";
        neg_denormal: return "neg_denormal";
        pos_denormal: return "pos_denormal";
        neg_zero: return "neg_zero";
        pos_zero: return "pos_zero";
        default: return "unknown";
    endcase
endfunction


always #5 clk = ~clk;

initial begin
  clk = 0;
  rst = 0;
  #20;
  rst = 1;
end

function string rnd_to_string(input logic [2:0] rnd);
    case (rnd)
        3'b000: return "IEEE_near";
        3'b001: return "IEEE_zero";
        3'b010: return "IEEE_pinf";
        3'b011: return "IEEE_ninf";
        3'b100: return "near_up";
        3'b101: return "away_zero";
        default: return "IEEE_near";
    endcase
endfunction

corner_case_t cases[12] = '{neg_SNAN, pos_SNAN, neg_QNAN, pos_QNAN, 
                                      neg_INF, pos_INF, 
                                      neg_normal, pos_normal, 
                                      neg_denormal, pos_denormal, 
                                      neg_zero, pos_zero};

int i, j;
corner_case_t case_a, case_b;

logic [31:0] expected_z;

initial begin
    int i, j;
    corner_case_t case_a, case_b;

    logic [31:0] expected_z;    
    @(posedge rst);

    a = $urandom();
    b = $urandom();

//IEEE_NEAR ROUNDING
  rnd = 3'b000; 
  repeat(3) @(posedge clk);
    
  expected_z = multiplication(rnd_to_string(rnd), a, b);
  $display("Testing with rnd=%b", rnd);
  if (z !== expected_z) begin
      $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
  end 
  else begin
      $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
  end
//IEEE_ZERO ROUNDING
  rnd = 3'b001; 
  repeat(3) @(posedge clk);
    
  expected_z = multiplication(rnd_to_string(rnd), a, b);
  $display("Testing with rnd=%b", rnd);
  if (z !== expected_z) begin
      $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
  end 
  else begin
      $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
  end
//IEEE_PINF ROUNDING
  rnd = 3'b010; 
  repeat(3) @(posedge clk);
    
  expected_z = multiplication(rnd_to_string(rnd), a, b);
  $display("Testing with rnd=%b", rnd);
  if (z !== expected_z) begin
      $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
  end 
  else begin
      $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
  end
//IEEE_NINF ROUNDING
  rnd = 3'b011; 
  repeat(3) @(posedge clk);
    
  expected_z = multiplication(rnd_to_string(rnd), a, b);
  $display("Testing with rnd=%b", rnd);
  if (z !== expected_z) begin
      $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
  end 
  else begin
      $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
  end
//NEAR_UP ROUNDING
  rnd = 3'b100; 
  repeat(3) @(posedge clk);
    
  expected_z = multiplication(rnd_to_string(rnd), a, b);
  $display("Testing with rnd=%b", rnd);
  if (z !== expected_z) begin
      $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
  end 
  else begin
      $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
  end

//AWAY_ZERO ROUNDING  
  rnd = 3'b101; 
  repeat(3) @(posedge clk);
    
  expected_z = multiplication(rnd_to_string(rnd), a, b);
  $display("Testing with rnd=%b", rnd);
  if (z !== expected_z) begin
      $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
  end 
  else begin
      $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
  end

for ( i = 0; i < 12; i++) begin
    for ( j = 0; j < 12; j++) begin

        case_a = cases[i];
        case_b = cases[j];

        a = corner_case_to_bits(case_a);
        b = corner_case_to_bits(case_b);

        repeat(3) @(posedge clk);
        
        expected_z = multiplication("IEEE_near", a, b);

        if(z !== expected_z) begin
            $display("FAIL: a=%h (%s), b=%h (%s), got z=%h, expected z=%h", 
                     a, corner_case_to_string(case_a), b, corner_case_to_string(case_b), z, expected_z);
        end 
        else begin
            $display("PASS: a=%h (%s), b=%h (%s), z=%h", 
                     a, corner_case_to_string(case_a), b, corner_case_to_string(case_b), z);
        end
    end
end
end
endmodule 