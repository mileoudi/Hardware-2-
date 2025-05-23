import rounding_pkg::*;
import exception_pkg::*;

module exception_mult (
    input logic [31:0] a, b,
    input logic [31:0] z_calc,
    input logic underflow, overflow,
    input logic inexact
    input logic [2:0] round_mode,

    output logic [31:0] z,
    output logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;
);