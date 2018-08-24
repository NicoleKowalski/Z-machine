.global asm_main
.extern crash
.extern decode_table_no_operand
.extern decode_table_one_operand
.extern decode_table_two_operands
.extern decode_table_variable_operands
.extern decode_table_extended_operations
.extern VERIFY

.global check_sliding_switch_status
.global decode_instructions_loop
.global memory_read
.global test_printing
.global zstack_operand
.global local_register_operand

.align 4
Zmemory: .space 2000000
Zstack: .space 1000000
ZMemoryLocalRegisters: .space 1000000
mySpace: .space 256
msn: .space 100
.align 4

.global Zstack
.global ZMemoryLocalRegisters
.global msn
.global mySpace

asm_main:
;@ Instruction set by: Merna Zaki and Nicole Kowalski
	;@ R0 and R1 is the first and second operand to decode
	;@ R3 is a branch, the branch target should be put into R3
	;@ R4 is ZPC
	;@ R5 is ZSP
	;@ R6 is the function call nesting depth
	MOV R6, #0
	;@ LDR R6, =Zstack
	;@ R7 is your Zmemory location - needs to hold 2MB
	LDR R7, =Zmemory ;@ initialize the memory
	MOV R8, #0
	STR R8, [R7] ;@ initially zero out the Zmemory
	;@ NOTE TO SELVES: we are allowed to have 1 megabyte for ourselves
	LDR R10,=mySpace
	;@ I GET R11 TO MYSELF
	LDR R12,=ZMemoryLocalRegisters

    LDR R8, =0xE0001004         ;@ memory address of the mode register
    LDR R9, =0x00000020         ;@ value to initalize the mode register
    STR R9, [R8]                ;@ set up the transmitter
    LDR R8, =0xE0001018         ;@ baud rate generator
    LDR R9, =#62                ;@ CD value to start baud rate setup
    STR R9, [R8]                ;@ start the baud rate setup
    LDR R8, =0xE0001034         ;@ baud rate diver address
    LDR R9, =#6                 ;@ value to complete baud rate setup
    STR R9, [R8]                ;@ complete the baud rate setup
    LDR R8, =0xE0001000         ;@ control register
    LDR R9, =0x00000117         ;@ enable and reset the UART
    STR R9, [R8]                ;@ enable and reset the UART

	check_sliding_switch_status:
    MOV R8, #0              ;@ reset R8 in the instance it is holding a value
    LDR R8, =0x41220000 	;@ address of the switches
    LDR R9, [R8]            ;@ read the switches
    LDR R12, =msn
    AND R11, R9, #32			;@ get state of debug
    STRB R11, [R12, #0]
    AND R8 ,R9, #128        ;@ extract the bit to check if upload status is set to 1
    CMP R8, #128            ;@ does it wish to upload?
	BNE check_sliding_switch_status
	MOV R8, #0
	debounce_switch:
	;@ jump here if the switch is moved to the on position
	;@ also jumps here if an upload is complete
		ADD R8, R8, #1
		CMP R8, #1000
	BNE debounce_switch
	;@ once done debouncing check the final status of SW7
	LDR R8, =0x41220000 	;@ address of the switches
    LDR R9, [R8]            ;@ read the switches
    AND R9 ,R9, #128        ;@ extract the bit to check if upload status is set to 1
    CMP R9, #128            ;@ does it wish to upload?
	BEQ reset_zmachine_for_upload
	BNE VERIFY

    reset_zmachine_for_upload:
    ;@ Before setting up the zmachine for upload the present recieving fifo must be flushed
    ;@ this is to prevent characters that are entered when upload is off from being transferred
    ;@ to the Z machine memory
    BL loop_to_clear_recieving_fifo
    ;@ zero out the zstack memory etc
    MOV R8, #0
    STR R8, [R7] 			;@ zero out the Zmemory
    MOV R5, R8 				;@ z stack pointer
    MOV R4, R8 				;@ z pc
    get_upload:
        MOV R8, #0              ;@ reset R8 in the instance it is holding a value
        LDR R8, =0x41220000 	;@ address of the switches
        LDR R9, [R8]            ;@ read the switches
        AND R9 ,R9, #128        ;@ extract the bit to check if upload status is set to 1
        CMP R9, #0              ;@ done uploading?
        MOV R8, #0
        BEQ debounce_switch
        ;@ check if the reciever is empty
        LDR R8, =0xE000102C			;@ check recieving FIFO
		LDR R9, [R8]
	 	AND R9, R9, #2 		;@ extract the one bit and then compare to see if it is 0
	 	CMP R9, #2 			;@ is it empty?
        BEQ get_upload
    store_to_zmemory:
    LDR R8,=0xE0001030 		;@ memory location to read/write for the UART
    LDRB R9, [R8]           ;@ read the contents -- which is one character
    STRB R9, [R7, R5]		;@ store the first 8 bits with the appropriate offset
    ADD R5, R5, #1
    B get_upload

	loop_to_clear_recieving_fifo:
    ;@ this is a function dedicated to clearing the remaining bits
    ;@ it is part of the process to store_to_zmemory and flush the recieving fifo on initial upload
		LDR R8,=0xE0001030			;@ memory location to read/write for the UART
		LDR R9, [R8]				;@ read the contents
	 	LDR R8, =0xE000102C			;@ check recieving FIFO
		LDR R9, [R8]
	 	AND R9, R9, #2 		;@ extract the one bit and then compare to see if it is 0
	 	CMP R9, #2 			;@ is it empty?
    BNE loop_to_clear_recieving_fifo
    MOV R15, R14

	DONE:
	LDR R9, =Zstack
	B DONE ;@ WHO KNOWS WHATS HAPPENING ANYMORE

    check_for_switch_change:
    ;@ this function exists to check if while the instructions are decoding the user
    ;@ decided to re-upload content
    LDR R8, =0x41220000 	;@ address of the switches
    LDR R9, [R8]            ;@ read the switches
    AND R8, R9, #128        ;@ extract the bit to check if upload status is set to 1
    CMP R8, #128            ;@ does it wish to upload?
    MOV R8, #0
    BEQ debounce_switch_change_2
    MOV R15, R14				;@ no change, continue with decoding instructions
    debounce_switch_change_2:
		ADD R8, R8, #1
		CMP R8, #1000
	BNE debounce_switch_change_2
	;@ once done debouncing check the final status of SW7
	LDR R8, =0x41220000 	;@ address of the switches
    LDR R9, [R8]            ;@ read the switches
    AND R9 ,R9, #128        ;@ extract the bit to check if upload status is set to 1
    CMP R9, #128            ;@ does it wish to upload?
	BEQ reset_zmachine_for_upload
	MOV R15, R14

    decode_instructions_loop:
	BL check_for_switch_change
	LDR R12,=ZMemoryLocalRegisters
	MOV R11, #0
    MOV R0, #0
    MOV R1, #0
    MOV R9, #0
    STR R9, [R10] 		;@ zero out all of the elements
    BL memory_read
    STR R4, [R10, #38]	;@store ZPC in case instruction is unknown
    ;@ NOTE: R8 now holds the entire opcode, do not touch it
    CMP R8, #0 ;@ is there no opcode?
    BEQ DONE
    ;@ determine the type of instruction in terms of alphabetical to numerical correspondence: A-1, B-2, C-3
    AND R9, R8, #192		;@ extract bits 6 and 7 that determine the "instruction" type
    LSR R9, R9, #6			;@ shift to the end
	CMP R9, #2				;@ check if the value is 'A-type'
    	LSREQ R9, R9, #4	;@ flush R9 and replace with appropriate value
    	ADDEQ R9, R9, #1
    	BEQ not_b_type
    CMP R9, #3				;@ check if the value is 'C-type'
    	LSREQ R9, R9, #4
    	ADDEQ R9, R9, #3
        BEQ not_b_type
	LSR R9, R9, #4 			;@ if neither are true then it is a b-type instruction
	ADD R9, R9, #2
	not_b_type:
    ;@ finally do a check to se e if it is x-type
    CMP R8, #190 ;@ 'X-type'
    	LSREQ R9, R9, #4
    	ADDEQ R9, R9, #4
    CMP R9, #4 ;@ THIS IS FOR X TYPE HANDLING
    BEQ crash
    STRB R9, [R10, #0] ;@ save the type
	CMP R9, #1 ;@ A-type?
    	BEQ a_type
    CMP R9, #2 ;@ B-type?
    	BEQ b_type
    CMP R9, #3 ;@ C-type?
    	BEQ c_type
    LDR R8, =#0xFFFFFFFF			;@ check if the ZPC is maxed out
    CMP R4, R8
    	BEQ check_sliding_switch_status	;@ reached the end of decoding
    B crash ;@ not a valid instruction type

    memory_read:
    LDRB R8, [R7, R4]	;@ R4 is holding the value of ZPC, location of first instruction
    ADD R4, R4, #1		;@ increment the ZPC by one
    MOV R15, R14

	a_type:
	;@ R10 legend [A-type op_count op_type instruction_indicator]
	AND R9, R8, #48 		;@ extract bits 5 and 4 of the opcode
	LSR R9, R9, #4			;@ shift to the end
	CMP R9, #3				;@ there are no operands
		LSREQ R9, R9, #4
		ADDEQ R9, R9, #0
		ADDNE R9, R9, #1 	;@ otherwise 1 operand
	STRB R9, [R10, #1]		;@ store the operand count
	AND R9, R8, #48			;@ for one operand extract bits 5 and 4-- this indicates what the operand is
	LSR R9, R9, #4
	STRB R9, [R10, #2]		;@ save the op_type
	AND R9, R8,	#15			;@ extract bits 3 through 0 of the opcode
	STRB R9, [R10, #3]		;@ save instruction indicator
	LDRB R9, [R10, #1]		;@ load the op_count
	CMP R9, #0
		BEQ decode_table_no_operand
	LDRB R9, [R10, #2]		;@ reload op_type
	;@ Now, fetch the corresponding operands
	MOV R11, #0
	CMP R9, #2 				;@ 10 means the operand is a register
		BEQ type_register_operand
	CMP R9, #1 				;@ 01 is an 8 bit constant
		BLEQ memory_read	;@ fetch the next 8 bits and store into R0
		ADDEQ R0, R8, #0
	CMP R9, #0 				;@ 00 16 bit constant
		BLEQ memory_read
		ADDEQ R0, R8, #0
		LSREQ R0, R0, #8
		BLEQ memory_read
		ADDEQ R0, R0, R8
    B decode_table_one_operand

	type_register_operand:
	LDRB R8, [R7, R4]	;@ R4 is holding the value of ZPC, location of first instruction
    ADD R4, R4, #1		;@ increment the ZPC by one
	CMP R8, #0xF
		BHI global_register_operand
	CMP R8, #0
		BLEQ zstack_operand
		BLNE local_register_operand
	;@ check the type and operand value once returning from the local_register_operand
	LDRB R9, [R10, #0]
	CMP R9, #1
		BEQ decode_table_one_operand
	CMP R11, #0
		BEQ b_type_second_operand
		BNE decode_table_two_operands
	global_register_operand:
	SUB R8, R8, #16
	LSL R8, R8, #1 		;@This is A
	STRB R11, [R10, #7]
	LDRH R11, [R10, #25]
	ADD R11, R8, R11
	LDRH R9 ,[R7, R11]
	REV16 R9, R9
	LDRB R11, [R10, #7]
	CMP R11, #0
		LSREQ R0, R0, #8
	    ADDEQ R0, R0, R9
	    LSRNE R1, R1, #8
	    ADDNE R1, R1, R9
	LDRB R9, [R10, #0]
	CMP R9, #1
		BEQ decode_table_one_operand
	CMP R11, #0
		BEQ b_type_second_operand
		BNE decode_table_two_operands

	zstack_operand:
	CMP R11, #0
	LDR R9, =Zstack
	SUB R5, R5, #2
    LDRH R9, [R9, R5]   ;@ pop the zstack into R0
    LSREQ R0, R0, #8
    ADDEQ R0, R0, R9
    LSRNE R1, R1, #8
    ADDNE R1, R1, R9
    ;@ need to decrement the 20th local register
    LDR R9,=#40
    LSL R9, R6, #6 		;@ multiply nesting depth by 64--B
    ADD R9, R9, #40		;@ add A and B giving you C the offset
    MOV R11, R9
    LDRH R9 ,[R12, R9]	;@ add c to the location of your zprodedure local zregister, this is the higher order byte
    SUB R9, R9, #1		;@ subtract 1 from the value in the register
    STRH R9, [R12, R11]	;@ store in the new value
	CMP R8, #0
	MOV R15, R14

    local_register_operand:
	SUB R8, R8, #1
	LSL R8, R8, #1 		;@ This is A
	LSL R9, R6, #6 		;@ This is B
	ADD R9, R9, R8 		;@ This is the offset of the zregister
	LDRH R9 ,[R12, R9]  ;@ Extracted operand
	CMP R11, #0
	LSREQ R0, R0, #8
    ADDEQ R0, R0, R9
    LSRNE R1, R1, #8
    ADDNE R1, R1, R9
    LDR R8, =#0xF
    CMP R8, #0xF
    MOV R15, R14

	b_type:
	;@ B-type operand count is always 2
	;@ R10 legend [B-type op1_type op2_type instruction_indicator]
	AND R9, R8, #64			;@ extract bit 6 from opcode
							;@ bit 6 indicates the type of the first operand
	LSR R9, R9, #6			;@ move to the end
							;@ if R9 is 1, its a one-byte register indicator
							;@ if R9 is 0, its a one-byte constant
	STRB R9, [R10, #1]		;@ save the first operand type
	AND R9, R8, #32			;@ extract bit 5 from opcode, the type of the second operand
	LSR R9, R9, #5			;@ move to the end
							;@ same R9 rules as the first operand
	STRB R9, [R10, #2]		;@ save the second operand type
	AND R9, R8, #31			;@ extract bits 4 through 0 from opcode
	STRB R9, [R10, #3]		;@ save the instruction indicator
	LDRB R9, [R10, #1]
	MOV R11, #0				;@ Flag for which operand we are extracting
	CMP R9, #0
		BNE type_register_operand
	MOV R11, #1
	STRB R11, [R10, #23]		;@ save 8-bit state
	BL memory_read
	MOV R0, R8
	b_type_second_operand:
	LDRB R9, [R10, #2]
	MOV R11, #1
	CMP R9, #0
		BNE type_register_operand
	LDRB R11, [R10, #23]
	ADD R11, R11, #2
	STRB R11, [R10, #23]		;@ save 8-bit state
	BL memory_read
	MOV R1, R8
	B decode_table_two_operands

	c_type:
	;@ returns 0 1 2 or -1 WHY DOES IT SAY IT SHOULD RETURN -1 IN THE DOCUMENTATION
	;@ R10 legend [C-type op_count blank_spot instruction_indicator]
	AND R9, R8, #32 ;@ extract the bit 5
	LSR R9, R9, #5 	;@ shift to the end
	CMP R9, #0
		LSREQ R9, R9, #2
		ADDEQ R9, R9, #2 	;@ if it is zero you have two operands
	CMP R9, #1
		LSREQ R9, R9, #2
		ADDEQ R9, R9, #1 	;@ if it is one you have a variable operand count
	STRB R9, [R10, #1]		;@ save the operand count
	AND R9, R8, #31			;@ extract bits 4 through 0 from opcode
	STRB R9, [R10, #3]		;@ save the instruction indicator
    BL memory_read
    MOV R11, #0
    ROR R9, R8, #6					;@rotate to cheat the system cuz cleverness
    LDR R8, =#0x3 					;@ initialize mask
    AND R8, R8, R9					;@ extract the next 2 bits
    ;@ first we need to check if this is a weird C type that has more than four operands
	LDR R12, [R10, #3]
	CMP R12, #0x0C
		BLEQ memory_read
		STREQB R8, [R10, #5]
		BEQ c_type_operand_loop
	CMP R12, #0x1A
		BLEQ memory_read
		STREQB R8, [R10, #5]
		BEQ c_type_operand_loop
	LDR R3, =#0xC0 	;@ default condition for if neither are true
	STRB R3, [R10, #5]
    c_type_operand_loop:
    LDR R12,=ZMemoryLocalRegisters
    CMP R11, #4	;@ are we done?
    	BEQ check_for_further_operands
    CMP R8, #3						;@ DONE
    	BEQ where_to_go_next
    CMP R8, #2						;@ Register stuff
    	BEQ c_type_register_operand
    CMP R8, #1 						;@ 8 bit constant
		BEQ extract_8_bit
	CMP R8, #0 						;@ 16 bit constant
		BEQ extract_16_bit
	c_type_continue_loop:
	ADD R11, R11, #1
	ROR R9, R9, #30 				;@ rotate to the next 2 bits
	LDR R8, =#0x3 					;@ clear mask
	AND R8, R8, R9					;@ extract the next 2 bits
    B c_type_operand_loop

    extract_8_bit:
    BL memory_read
    LDR R12, =#1
    LSL R12, R12, R11
    LDRB R10, [R10, #23]
   	ORR R12, R12, R10			;@update flag for 8 bit constant (sign stuff)
   	LDR R10,=mySpace
    STRB R12, [R10, #23]		;@flag for 8 bit constant for sign stuff
    LDR R12,=ZMemoryLocalRegisters
    CMP R11, #0
    	ADDEQ R0, R0, R8
    CMP R11, #1
    	ADDEQ R1, R1, R8
    CMP R11, #2
    	BLEQ c_load_to_first_position
    CMP R11, #3
    	BLEQ c_load_to_second_position
	CMP R11, #4
    	BLEQ c_load_to_third_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #5
    	BLEQ c_load_to_fourth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #6
    	BLEQ c_load_to_fifth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #7
    	BLEQ c_load_to_sixth_position
      	BEQ c_type_continue_loop_further_operand
    B c_type_continue_loop

    extract_16_bit:
    BL memory_read
    CMP R11, #0
    	ADDEQ R0, R0, R8 			;@ add in higher order bits
    	LSLEQ R0, R0, #8
    	BLEQ memory_read
    	ADDEQ R0, R0, R8			;@ add in the lower order bits
    CMP R11, #1
    	ADDEQ R1, R1, R8			;@ add in higher order bits
    	LSLEQ R1, R1, #8
    	BLEQ memory_read
    	ADDEQ R1, R1, R8			;@ add in the lower order bits
    CMP R11, #2
    	BLEQ c_load_to_first_position
    CMP R11, #3
    	BLEQ c_load_to_second_position
	CMP R11, #4
    	BLEQ c_load_to_third_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #5
    	BLEQ c_load_to_fourth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #6
    	BLEQ c_load_to_fifth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #7
    	BLEQ c_load_to_sixth_position
      	BEQ c_type_continue_loop_further_operand
    B c_type_continue_loop

	c_type_register_operand:
	LDRB R8, [R7, R4]	;@ R4 is holding the value of ZPC, location of first instruction
    ADD R4, R4, #1		;@ increment the ZPC by one
	CMP R8, #0
		BEQ c_zstack_operand
	CMP R8, #0xF
	   BLS c_local_register_operand ;@ branch if less than
	c_global_register_operand:
	SUB R8, R8, #16
	LSL R8, R8, #1 		;@This is A
	STRB R11, [R10, #7]
	LDRH R11, [R10, #25]
	ADD R11, R8, R11
	REV16 R9, R9
	LDRH R9 ,[R7, R11]
	LDRB R11, [R10, #7]
	CMP R11, #0
		LSREQ R0, R0, #8
	    ADDEQ R0, R0, R9
    CMP R11, #1
	    LSREQ R1, R1, #8
	    ADDEQ R1, R1, R9
	CMP R11, #2
		BLEQ c_load_to_first_position
	CMP R11, #3
		BLEQ c_load_to_second_position
	CMP R11, #4
    	BLEQ c_load_to_third_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #5
    	BLEQ c_load_to_fourth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #6
    	BLEQ c_load_to_fifth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #7
    	BLEQ c_load_to_sixth_position
      	BEQ c_type_continue_loop_further_operand
	B c_type_continue_loop

	c_zstack_operand:
	STRB R11, [R10, #7]
	;@CMP R11, #0
	LDR R10, =Zstack
	SUB R5, R5, #2      ;@ change the ZSP
    LDRB R10, [R10, R5]   ;@ pop the zstack into temp
    ;@ need to decrement the 20th local register
    CMP R11, #0
		LSREQ R0, R0, #8
	    ADDEQ R0, R0, R10
    CMP R11, #1
	    LSRNE R1, R1, #8
	    ADDNE R1, R1, R10
	CMP R11, #2
		BLEQ c_load_to_first_position
	CMP R11, #3
		BLEQ c_load_to_second_position
	CMP R11, #4
    	BLEQ c_load_to_third_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #5
    	BLEQ c_load_to_fourth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #6
    	BLEQ c_load_to_fifth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #7
    	BLEQ c_load_to_sixth_position
      	BEQ c_type_continue_loop_further_operand
	LSL R10, R6, #6 		;@ multiply nesting depth by 64--B
    ADD R10, R10, #40		;@ add A and B giving you C the offset
    LDRH R11, [R12, R10]
	SUB R11, R11, #1			;@ subtract 1 from the value in the register
	STRH R11, [R12, R10]
    ;@ restore the registers
    LDR R10, =mySpace
    LDRB R11, [R10, #7]
	B c_type_continue_loop

    c_local_register_operand:
	SUB R8, R8, #1
	LSL R8, R8, #1 		;@ This is A
	MOV R10, #0
	LSL R10, R6, #6 		;@ This is B
	ADD R10, R10, R8 		;@ This is the offset of the zregister
	LDRH R10, [R12, R10]  	;@ Extracted operand
	CMP R11, #0
		LSREQ R0, R0, #8
	    ADDEQ R0, R0, R10
    CMP R11, #1
	    LSREQ R1, R1, #8
	    ADDEQ R1, R1, R10
	CMP R11, #2
		BLEQ c_load_to_first_position
	CMP R11, #3
		BLEQ c_load_to_second_position
	CMP R11, #4
    	BLEQ c_load_to_third_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #5
    	BLEQ c_load_to_fourth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #6
    	BLEQ c_load_to_fifth_position
    	BEQ c_type_continue_loop_further_operand
    CMP R11, #7
    	BLEQ c_load_to_sixth_position
      	BEQ c_type_continue_loop_further_operand
	LDR R10,=mySpace
   	B c_type_continue_loop

	c_load_to_first_position:
    	LDRH R10, [R10, #32]
	MOV R15, R14

	c_load_to_second_position:
		LDRH R10, [R10, #64]
	MOV R15, R14

	c_load_to_third_position:
		LDRH R10, [R10, #66]
	MOV R15, R14

	c_load_to_fourth_position:
		LDRH R10, [R10, #68]
	MOV R15, R14

	c_load_to_fifth_position:
		LDRH R10, [R10, #70]
	MOV R15, R14

	c_load_to_sixth_position:
		LDRH R10, [R10, #72]
	MOV R15, R14

	where_to_go_next:
	LDRB R9, [R10, #1]
	CMP R9, #2
		BEQ decode_table_two_operands
	B decode_table_variable_operands

	check_for_further_operands:
	LDR R12, [R10, #5]
	CMP R12, #0xC0
    	LDREQ R12,=ZMemoryLocalRegisters
    	BEQ decode_table_variable_operands
    MOV R9, R12
    ROR R9, R8, #6					;@rotate to cheat the system cuz cleverness
    LDR R8, =#0x3 					;@ initialize mask
    AND R8, R8, R9					;@ extract the next 2 bits
    c_type_operand_loop_further_operand:
    LDR R12,=ZMemoryLocalRegisters
    CMP R11, #8	;@ are we done?
    	BEQ decode_table_variable_operands
    CMP R8, #3						;@ DONE
    	BEQ decode_table_variable_operands
    CMP R8, #2						;@ Register stuff
    	BEQ c_type_register_operand
    CMP R8, #1 						;@ 8 bit constant
		BEQ extract_8_bit
	CMP R8, #0 						;@ 16 bit constant
		BEQ extract_16_bit
	c_type_continue_loop_further_operand:
	ADD R11, R11, #1
	ROR R9, R9, #30 				;@ rotate to the next 2 bits
	LDR R8, =#0x3 					;@ clear mask
	AND R8, R8, R9					;@ extract the next 2 bits
    B c_type_operand_loop_further_operand

