`timescale 1ns/1ps
`include "multiplication.sv"
module tb_mult;

logic clk, rst_n;
logic [31:0] a, b;
logic [2:0] rnd;
logic [31:0] z;
logic [7:0] status;

fp_mult dut (
    .clk(clk),
    .rst_n(rst_n),
    .a(a),
    .b(b),
    .rnd(rnd),
    .z(z),
    .status(status)
);

always #5 clk = ~clk;

initial begin
  clk = 0;
  rst_n = 0;
  #20;
  rst_n = 1;
end

function string rnd_to_string(input logic [2:0] rnd);
    case (rnd)
        3'b000: return "IEEE_near";
        3'b001: return "IEEE_zero";
        3'b010: return "IEEE_pinf";
        3'b011: return "IEEE_ninf";
        3'b100: return "away_zero";
        default: return "IEEE_near";
    endcase
endfunction

initial begin @(posedge rst_n);

  logic [31:0] expected_z;
  for (int test_num = 0; test_num < 100; test_num++) begin
    a = $urandom();
    b = $urandom();

    rnd = 3'b000; 
    repeat(3) @(posedge clk);
    
    expected_z = multiplication(a, b, rnd_to_string(rnd));

    if (z !== expected_z) begin
        $display("FAIL: a=%h, b=%h, rnd=%b, got z=%h, expected z=%h", a, b, rnd, z, expected_z);
    end else begin
        $display("PASS: a=%h, b=%h, rnd=%b, z=%h", a, b, rnd, z);
    end

  end
    $finish;
end 
