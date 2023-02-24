///////////////////////////////////////////
// shifter.sv
//
// Written: David_Harris@hmc.edu, Sarah.Harris@unlv.edu, kekim@hmc.edu
// Created: 9 January 2021
// Modified: 6 February 2023
//
// Purpose: RISC-V 32/64 bit shifter
// 
// Documentation: RISC-V System on Chip Design Chapter 4 (Figure 4.5, Table 4.3)
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

`include "wally-config.vh"

module shifternew (
  input  logic [`XLEN:0]     shA,                         // Source
  input  logic [`LOG_XLEN-1:0] Amt,                         // Shift amount
  input  logic                 Right, Arith, W64, Rotate,   // Shift right, arithmetic, RV64 W-type shift
  output logic [`XLEN-1:0]     Y);                          // Shifted result

  logic [2*`XLEN-2:0]      z, zshift;                       // Input to funnel shifter, shifted amount before truncated to 32 or 64 bits
  logic [`LOG_XLEN-1:0]    amttrunc, offset, CondOffsetTrunc;                // Shift amount adjusted for RV64, right-shift amount


  if (`XLEN==32) begin:shifter // RV32
    always_comb  // funnel mux
      if (Right)  z = {{31{shA[32]}}, shA[31:0]};
      else        z = {shA[31:0], 31'b0};
    assign amttrunc = Amt; // shift amount
  end else begin:shifter  // RV64
    always_comb  // funnel mux
      if (Right)  z = {{63{shA[64]}},shA[63:0]};
      else        z = {shA[63:0],{63'b0}};
    assign amttrunc = W64 ? {1'b0, Amt[4:0]} : Amt; // 32- or 64-bit shift
  end
  // Handle left and right shifts with a funnel shifter.
  // For RV32, only 32-bit shifts are needed.   
  // For RV64, 32- and 64-bit shifts are needed, with sign extension.
  /*
  // Funnel shifter input (see CMOS VLSI Design 4e Section 11.8.1, note Table 11.11 shift types wrong)
  if (`XLEN==32) begin:shifter // RV32
    always_comb  // funnel mux
      if (Right) 
        if (Arith) z = {{31{A[31]}}, A};
        else       z = {31'b0, A};
      else         z = {A, 31'b0};
    assign amttrunc = Amt; // shift amount
  end else begin:shifter  // RV64
    always_comb  // funnel mux
      if (W64) begin // 32-bit shifts
        if (Right)
          if (Arith) z = {64'b0, {31{A[31]}}, A[31:0]};
          else       z = {95'b0, A[31:0]};
        else         z = {32'b0, A[31:0], 63'b0};
      end else begin
        if (Right)
          if (Arith) z = {{63{A[63]}}, A};
          else       z = {63'b0, A};
        else         z = {A, 63'b0};         
      end
    assign amttrunc = W64 ? {1'b0, Amt[4:0]} : Amt; // 32- or 64-bit shift
  end
  */
  /*

  if (`ZBB_SUPPORTED) begin: rotFunnel // HANDLES ROTATE
    if (`XLEN==32) begin:shifter // RV32
      always_comb  // funnel mux
        if (Right) 
          if (Rotate)  z = {A[30:0], A[31:0]};                        //ror (rv32)
          else
            if (Arith) z = {{31{A[31]}}, A};
            else       z = {31'b0, A};
        else
          if (Rotate)  z = {A[31:0], A[31:1]};                         //rol (rv32)
          else         z = {A, 31'b0};
      assign amttrunc = Amt; // shift amount
    end else begin:shifter  // RV64
      always_comb  // funnel mux
        if (W64) begin // 32-bit shifts
          if (Right)
            if (Rotate)  z = {{64'b0},A[30:0],A[31:0]}; //rorw
            else
              if (Arith) z = {64'b0, {31{A[31]}}, A[31:0]};
              else       z = {95'b0, A[31:0]};
          else         
            if (Rotate)  z = {{64'b0},A[31:0],A[31:1]}; //rolw
            else         z = {32'b0, A[31:0], 63'b0};
        end else begin
          if (Right)
            if (Rotate)  z = {A[62:0], A[63:0]};        //ror
            else
              if (Arith) z = {{63{A[63]}}, A};
              else       z = {63'b0, A};
          else
            if (Rotate)  z = {A[63:0], A[63:1]};        //rol
            else         z = {A, 63'b0};         
        end
      assign amttrunc = W64 ? {1'b0, Amt[4:0]} : Amt; // 32- or 64-bit shift
    end
  end else begin: norotFunnel
    if (`XLEN==32) begin:shifter // RV32
      always_comb  // funnel mux
        if (Right) 
          if (Arith) z = {{31{A[31]}}, A};
          else       z = {31'b0, A};
        else         z = {A, 31'b0};
      assign amttrunc = Amt; // shift amount
    end else begin:shifter  // RV64
      always_comb  // funnel mux
        if (W64) begin // 32-bit shifts
          if (Right)
            if (Arith) z = {64'b0, {31{A[31]}}, A[31:0]};
            else       z = {95'b0, A[31:0]};
          else         z = {32'b0, A[31:0], 63'b0};
        end else begin
          if (Right)
            if (Arith) z = {{63{A[63]}}, A};
            else       z = {63'b0, A};
          else         z = {A, 63'b0};         
        end
      assign amttrunc = W64 ? {1'b0, Amt[4:0]} : Amt; // 32- or 64-bit shift
    end
  end
  */
  // Opposite offset for right shifts
  assign offset = Right ? amttrunc : ~amttrunc;
  //if (`XLEN == 64) assign CondOffsetTrunc = (W64 & Rotate) ? {{1'b0}, offset[4:0]} : offset;
  //else assign CondOffsetTrunc = offset;
  
  // Funnel operation
  assign zshift = z >> offset;
  assign Y = zshift[`XLEN-1:0];    
endmodule


