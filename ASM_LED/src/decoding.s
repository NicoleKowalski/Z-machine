
.global crash
.global help
.global get_location_of_register
.global send_to_UART
.global determine_crash_counter
.global print_operand
.global get_zstack_location
.global local_register_location
.global global_register_location
.global crash_
.global extract_sign_bit
.global branch
.global sign_extend_16_bit
.global store_to_register_location
.global RETURN
.global check_if_long_branch
.global calls

.extern Zstack
.extern mySpace
.extern decode_table_no_operand
.extern decode_instructions_loop
.extern RTRUE
.extern RFALSE

	determine_crash_counter:
	MOV R12, #0
	LDRB R9, [R10, #0]
	CMP R9, #2
	        LSREQ R12, R12, #30 		;@ B type only has a one byte register indicator or a one byte constant
	        ADDEQ R12, R12, #2
	        BEQ crash
	CMP R9, #1
	        BEQ a_type_crash
	CMP R9, #3
	        BEQ c_type_crash
	B crash

	c_type_crash:
	LDR R4, [R10, #38]
	BL memory_read               ;@ get the types of the operands
	ADD R12, R12, #1			;@ COMPENSATE FOR THE WEIRD TYPE BYTE
	MOV R11, #0
	ROR R9, R8, #6                                        ;@rotate to cheat the system cuz cleverness
	LDR R8, =#0x3                                         ;@ initialize mask
	AND R8, R8, R9                                        ;@ extract the next 2 bits
	c_type_crash_operand_loop:
	CMP R11, #4                                                ;@ DONE
	    BEQ crash
	CMP R8, #3                                                ;@ DONE
	    BEQ crash
	CMP R8, #2                                                ;@ Register stuff
	    ADDEQ R12, R12, #1
	CMP R8, #1                                                 ;@ 8 bit constant
	        ADDEQ R12, R12, #1
	CMP R8, #0                                                 ;@ 16 bit constant
	        ADDEQ R12, R12, #2
	c_type_continue_loop:
	ADD R11, R11, #1
	ROR R9, R9, #30                                 ;@ rotate to the next 2 bits
	LDR R8, =#0x3                                         ;@ clear mask
	AND R8, R8, R9                                        ;@ extract the next 2 bits
	B c_type_crash_operand_loop

	a_type_crash:
	LDRB R9, [R10, #1]
	CMP R9, #0
	        LDREQB R12, =#0
	        BEQ crash
	LDRB R9, [R10, #2]
	CMP R9, #2
	        ADDEQ R12, R12, #1
	CMP R9, #1
	        ADDEQ R12, R12, #1
	CMP R9, #0
	        ADDEQ R12, R12, #2
	B crash

    crash:
    LDR R4, [R10, #38];@ load the original ZPC
    MOV R11, #1
	MOV R0, R4
	STRH R12, [R10, #15]
	BL getSizeNum
	LDRH R12, [R10, #15]
	MOV R8, R3
	zpc_loop:
		STRH R12, [R10, #15]
		BL getNextChar 	;@ ask for character
		LDRH R12, [R10, #15]
		MOV R9, R3
		STRB R8, [R10, #11]
		BL send_to_UART        	;@ send to UART
		LDRB R8, [R10, #11]		;@ SOS COUNTER
		CMP R8, R11             ;@ see if we are at the end
		ADD R11, R11, #1
		BNE zpc_loop
	LDR R9, =#0x20
	BL send_to_UART
	MOV R11, #1
	SUB R4, R4, #1 		;@ need to start from 0
	ADD R12, R12, #1 	;@ include the opcode
	opcode_operand_loop:
		BL memory_read ;@ get the unknown OPCODE at that location
		MOV R0, R8
		STRH R12, [R10, #15]
		BL getSizeofHex
		LDRH R12, [R10, #15]
		MOV R8, R3
	 	BL getNextChar	;@ ask for first character
		MOV R9, R3
		BL send_to_UART
		;@ instructions regarding second character
		STRH R12, [R10, #15]
		BL getNextChar			;@ ask for second character
		LDRH R12, [R10, #15]
		MOV R9, R3
		BL send_to_UART
		LDR R9, =#0x20			;@ add in spaces after a byte
		BL send_to_UART
		CMP R11, R12
		ADD R11, R11, #1
		BNE opcode_operand_loop
    crash_:
    LDR R8, =0x41210000 ;@ address of lights
    LDR R9, =0xFF
    STR R9, [R8]
    B crash_

	help:
		B help

    get_location_of_register:
    BL memory_read ;@ get the last byte
    store_to_register_location: ;@ this label exists so PUSH/PULL/RETURN skip the memory read
	CMP R8, #0
		BEQ get_zstack_location
	CMP R8, #0xF
	   BLS local_register_location	;@ branch if less than
	global_register_location:
	SUB R8, R8, #16
	LSL R8, R8, #1 		;@ This is A
	LDRH R11, [R10, #25] ;@ get the location of the global register
	ADD R11, R8, R11
	REV16 R9, R9
	STRH R9 ,[R7, R11]	;@ store the result into the global register
	B finish
	get_zstack_location:
	;@CMP R11, #0
	LDR R10, =Zstack
    STRB R9, [R10, R5]   ;@ store the result into the stack
    LDR R10,=mySpace
    ADD R5, R5, #1
    ;@ need to increment the 20th local register
    LDR R9,=#40			;@ this is A
    LSL R9, R6, #6 		;@ multiply nesting depth by 64--B
    ADD R9, R9, #40		;@ add A and B giving you C the offset
    LDRH R8, [R12, R9]
	ADD R8, R8, #1			;@ ADD 1 from the value in the register
	STRH R8, [R12, R9]
    B finish
    local_register_location:
	SUB R8, R8, #1
	LSL R8, R8, #1 			;@ This is A
	LSL R11, R6, #6 		;@ This is B
	ADD R11, R11, R8 		;@ This is the offset of the zregister
	STRH R9, [R12, R11]  ;@ store the result into the local register
	finish:
	B decode_instructions_loop

	send_to_UART:
	STRB R9, [R10, #10]
	checkBuffer:
 		LDR R8, =0xE000102C
 		LDR R8, [R8]
 		LDR R9, =0x8
 		AND R8, R8, R9
 		CMP R8, R9 ;@ is it empty?
	BNE checkBuffer
	LDRB R9, [R10, #10]
    LDR R8,=0xE0001030 		;@ memory location to read/write for the UART
    STR R9, [R8]
    MOV R15, R14

    branch:
    	BL memory_read
    	MOV R9, #0x80
    	AND R9,R9, R8		;@extracted bit 7
    	CMP R9, #0
    	BEQ continue_branch
    	B decode_instructions_loop

	continue_branch:
		MOV R9, #0x40
		AND R9, R9, R8		;@extract bit 6
		CMP R9, #0x40
		BEQ short_branch
		BNE long_branch

    short_branch:
    	MOV R9, #0x3F
    	AND R9, R9, R8		;@extract next 6 bits
    	CMP R9, #0
    		STRB R9, [R10, #3]
    		BEQ RFALSE
    	CMP R9, #1
    		STRB R9, [R10, #3]
    		BEQ RTRUE
    	;@get new ZPC value where R9 is the offset
		ADD R4, R4, R9
		SUB R4, R4, #2	;@new ZPC = (old ZPC + offset) - 2
		B decode_instructions_loop

    back_to_instruction:
    	MOV R15, R14

    long_branch:
    	;@ step 2: extract 6 from the first branch byte
    	MOV R9, #0x3F
    	AND R9, R9, R8		;@extract next 6 bits
    	;@ step 2: multiply by 256 (In other words we are shifting it... strangely)
    	LDR R8, =#256
    	MUL R9, R9, R8
    	;@ step 1: get the second branch byte
		BL memory_read
		;@ step 3: add the two branch bytes
		ADD R9, R9, R8
		;@ step 4: preform a dandy sign extension
		LDR R8, =#0x2000
		AND R8, R8, R9 		;@extracted top most bit
		MOV R11, #0
		start_sign_extend:
		CMP R11, #18
			BEQ done_sign_extend
		LSL R8, R8, #1
		ADD R9, R9, R8		;@duuuuuuupplicate top most bit
		ADD R11, R11, #1
		B start_sign_extend
		;@get new ZPC value where R9 is the offset
		done_sign_extend:
			ADD R4, R4, R9
			SUB R4, R4, #2	;@new ZPC = (old ZPC + offset) - 2
		B decode_instructions_loop

	extract_sign_bit:
		LDR R8, =#0x80		;@ mask
        AND R8, R9, R8		;@ extract signed bit
    	LSL R8, R8, #8
    	ORR R9, R8, R9		;@ signed bit is now in 16th bit
    	LDR R8, =#0x80
    	BIC R9, R9, R8		;@ clear original signed bit
		MOV R15, R14

	sign_extend_16_bit:
		LDR R8, =#0x8000		;@ mask
        AND R8, R9, R8		;@ extract signed bit
   		loop_extend:
       		LSL R8, R8, #1
			CMP R11, #16
				BEQ branch_link_back
			ORR R9, R9, R8		;@duuuuuuupplicate top most bit
			ADD R11, R11, #1
		B loop_extend

	branch_link_back:
		MOV R15, R14

	RETURN:
	;@ Rll holds the return value
	;@ Step 2: Pop the ZStack as many times as the 20th local register
	LDR R12, =ZMemoryLocalRegisters
	LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
	ADD R9, R9, #40                ;@ add A and B giving you C the offset
	MOV R10, R9
	LDRH R9 ,[R12, R9]        ;@ add c to the location of your zprodedure local zregister, this is the higher order byte
	continue_poping_the_stack:
	CMP R9, #0
	        BEQ done_popping_the_zstack
	LDR R9, =Zstack
	LDRH R0, [R9, R5]   ;@ pop the zstack into R0
	SUB R5, R5, #1
	SUBNE R9, R9, #1
	STRH R9, [R12, R10]        ;@ store in the new value
	BNE continue_poping_the_stack
	done_popping_the_zstack:
	;@ Step 3: set the ZPC to the content of the 24th local register
	LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
	ADD R9, R9, #48                ;@ add A and B giving you C the offset
	LDRH R4, [R12, R9]
	;@ Step 4: check 28th local
	;@ this register is both the target register and indicates if you want to save the return value
	;@ if it holds the value of 0xFFFF then you do not want to save the value
	LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
	ADD R9, R9, #56                ;@ add A and B giving you C the offset
	LDRH R9, [R12, R9]
	;@ DO NOT MODIFY R9 PAST THIS POINT
	;@ Step 5: decrement the nesting depth by 1
	SUB R6, R6, #1
	;@ below is the setup for the final CMP
	LDR R10,=#0xFFFF
	MOV R8, R9 	;@ set up for store_to_register_location
	MOV R9, R11 ;@ value to potentially be stored
	CMP R9, R10
		LDR R10,=mySpace
	    BNE store_to_register_location
	    BEQ decode_instructions_loop

    check_if_long_branch:
    MOV R9, #0x40
    AND R9, R9, R8          ;@extract bit 6
    CMP R9, #0x40
    	ADDNE R4, R4, #1    ;@increment ZPC
	MOV R9, #1				;@ ensure the flags are preserved
	CMP R9, #1
    MOV R15, R14

    calls:
    ADD R6, R6, #1      ;@ increment nesting depth
    MOV R8, #0
    LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #0                 ;@ add A and B giving you C the offset
    MOV R3, #0
    zero_out_local_zregisters:
        ADD R9, R9, R3
    	STRH R8, [R12, R9]        	   ;@ store the operand
    	CMP R3, #64
    	ADDNE R3, R3, #2
    	BNE zero_out_local_zregisters
    CMP R11, #0         ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
    ;@store the first operand
    LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #0                 ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]        	   ;@ store the operand
    CMP R11, #1                    ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
    ;@store the second operand
    LDRH R1, [R10, #32]
    LSL R9, R6, #6              	 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #2        	         ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]       		 ;@ store the operand
    CMP R11, #2        				 ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
    ;@store the third operand
    LDRH R1, [R10, #64]
    LSL R9, R6, #6                	 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #4               	 ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]       		 ;@ store the operand
     CMP R11, #3        				 ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
      ;@store the fourth operand
    LDRH R1, [R10, #66]
    LSL R9, R6, #6              	 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #6        	         ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]       		 ;@ store the operand
    CMP R11, #4        				 ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
        ;@store the fifth operand
    LDRH R1, [R10, #68]
    LSL R9, R6, #6              	 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #8        	         ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]       		 ;@ store the operand
    CMP R11, #5        				 ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
        ;@store the sixth operand
    LDRH R1, [R10, #70]
    LSL R9, R6, #6              	 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #10        	         ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]       		 ;@ store the operand
    CMP R11, #6        				 ;@ Im assuming the instruction will store its operand count in here
        BEQ done_storing_operands
        ;@store the seventh operand
    LDRH R1, [R10, #72]
    LSL R9, R6, #6              	 ;@ multiply nesting depth by 64--B
    ADD R9, R9, #12        	         ;@ add A and B giving you C the offset
    STRH R1, [R12, R9]       		 ;@ store the operand
    done_storing_operands:
        LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
        ADD R9, R9, #44                ;@ add A and B giving you C the offset
        STRH R11, [R12, R9]       	   ;@ store the counter for the number of operands in the 22nd register

        LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
        ADD R9, R9, #48                ;@ add A and B giving you C the offset
        STRH R4, [R12, R9]             ;@ store the current ZPC in the 24th local register

        LDRB R9, [R10, #4]             ;@load flag for if destination register exists
        CMP R9, #1
        LDRNEB R8, =#0xffff            ;@ if there is no destination register
        BLEQ memory_read               ;@fetch destination register
        LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
        ADD R9, R9, #56                ;@ add A and B giving you C the offset
        STRH R8, [R12, R9]        ;@ store the possible destination register in the 28th local register

        LSL R0, R0, #2      ;@multiply call target by 4
        ADD R4, R0, #1      ;@add 1 to the calling target and store it in the ZPC
        B decode_instructions_loop
