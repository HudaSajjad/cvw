///////////////////////////////////////////
// aes_Inv_shiftrow.sv
//
// Written: ryan.swann@okstate.edu, james.stine@okstate.edu
// Created: 20 February 2024
//
// Purpose: AES Shiftrow
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
// 
// Copyright (C) 2021-24 Harvey Mudd College & Oklahoma State University
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

module aes_Inv_shiftrow(input logic [127:0] DataIn,
			output logic [127:0] DataOut);
		    
   // Separate the first (Least Significant) word into bytes
   logic [7:0] 				     w0_b0 = DataIn[7:0];		
   logic [7:0] 				     w0_b1 = DataIn[15:8];	
   logic [7:0] 				     w0_b2 = DataIn[23:16];	
   logic [7:0] 				     w0_b3 = DataIn[31:24];	
   // Separate the second word into bytes
   logic [7:0] 				     w1_b0 = DataIn[39:32];	
   logic [7:0] 				     w1_b1 = DataIn[47:40];	
   logic [7:0] 				     w1_b2 = DataIn[55:48];	
   logic [7:0] 				     w1_b3 = DataIn[63:56];	
   // Separate the third word into bytes
   logic [7:0] 				     w2_b0 = DataIn[71:64];	
   logic [7:0] 				     w2_b1 = DataIn[79:72];	
   logic [7:0] 				     w2_b2 = DataIn[87:80];	
   logic [7:0] 				     w2_b3 = DataIn[95:88];	
   // Separate the fourth (Most significant) word into bytes
   logic [7:0] 				     w3_b0 = DataIn[103:96];	
   logic [7:0] 				     w3_b1 = DataIn[111:104];	
   logic [7:0] 				     w3_b2 = DataIn[119:112];	
   logic [7:0] 				     w3_b3 = DataIn[127:120];    
   // The output words are composed of sets of the input bytes.
   logic [31:0] 			     out_w0 = {w0_b3, w1_b2, w2_b1, w3_b0};
   logic [31:0] 			     out_w1 = {w3_b3, w0_b2, w1_b1, w2_b0};
   logic [31:0] 			     out_w2 = {w2_b3, w3_b2, w0_b1, w1_b0};
   logic [31:0] 			     out_w3 = {w1_b3, w2_b2, w3_b1, w0_b0};   
   
   assign DataOut = {out_w0, out_w1, out_w2, out_w3};
   
endmodule
