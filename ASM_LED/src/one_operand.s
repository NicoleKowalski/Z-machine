.global decode_table_one_operand
.extern determine_determine_crash_counter_counter
.extern msn
.extern ZMemoryLocalRegisters
.extern debug_mode
.extern zstack_operand
.extern local_register_operand

.extern get_zstack_location
.extern local_register_location
.extern global_register_location
.extern RETURN
.extern check_if_long_branch
.extern calls
.extern find_the_character

 decode_table_one_operand:
    LDR R12, =msn
 	LDRB R9, [R12, #0]
 	CMP R9, #0x20
 	BNE skip_debug
		MOV R9, #65					;@print A
		BL send_to_UART
		STRH R0, [R10, #17] ;@ 17 THESE ARE THE NEW VALUES
    	STRH R1, [R10, #19] ;@ 19
    	STRH R3, [R10, #21] ;@ 21
    	LDR R9, =#0x20
		BL send_to_UART		;@print space
		LDRB R0, [R10, #3]
    	BL getSizeofHex
		LSR R12, R12, #30
		ADD R12, R12, R3			;@ store size
		MOV R8, #1
		;@print instruction
    	print_operand_instruction:
			STRB R12, [R10, #24]	;@this offset is okay
			STRB R8, [R10, #11]
			BL getNextChar
			MOV R9, R3
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_instruction
		;@ move onto getting the first operand
		LDRH R0, [R10, #17]
		BL getSizeofHex
		LDR R9, =#0x20
		BL send_to_UART		;@print space
		LSR R12, R12, #30
		ADD R12, R12, R3			;@store size
		MOV R8, #1
		print_operand_1:
			STRB R12, [R10, #24]
			BL getNextChar
			MOV R9, R3
			STRB R8, [R10, #11]
			BL send_to_UART
			LDRB R8, [R10, #11]
			LDRB R12, [R10, #24]
			CMP R12, R8
			ADD R8, R8, #1
			BNE print_operand_1
    	LDR R9, =#0x20
		BL send_to_UART		;@print space
		LDRH R0, [R10, #17]
    	LDRH R1, [R10, #19]
		LDRH R3, [R10, #21]
	skip_debug:
 	LDR R12, =ZMemoryLocalRegisters
    LDR R10,=mySpace
    LDRB R9, [R10, #3]
    CMP R9, #0x0
        BEQ JZ
    CMP R9, #0x1
        BEQ GET_SIBLING
    CMP R9, #0x2
        BEQ GET_CHILD
    CMP R9, #0x3
        BEQ GET_PARENT
    CMP R9, #0x4
        BEQ GET_PROP_LEN
    CMP R9, #0x5
        BEQ INC
    CMP R9, #0x6
        BEQ DEC
    CMP R9, #0x7
        BEQ PRINT_ADDR
    CMP R9, #0x8
        BEQ CALL_1S
    CMP R9, #0x9
        BEQ REMOVE_OBJ
    CMP R9, #0xA
        BEQ PRINT_OBJ
    CMP R9, #0xB
        BEQ RET 
    CMP R9, #0xC
        BEQ JUMP
    CMP R9, #0xD
        BEQ PRINT_PADDR
     CMP R9, #0xF
        BEQ CALL_1N
    B determine_crash_counter
    
    JZ:
    CMP R0, #0
   		BEQ branch
   	BL memory_read
   	BL check_if_long_branch
    B decode_instructions_loop
    
    GET_SIBLING:
     	LDRH R8, [R10, #34]	;@ get Objtable
    	LSL R0, R0, #7
    	ADD R0, R0, #8
    	ADD R0, R0, R8
    	LDRH R0, [R7, R0]
    	REV16 R0, R0
    	BL memory_read
    	BL store_register_operand
    	CMP R0, #0
    		BNE branch
    BL memory_read
    BL check_if_long_branch
    B decode_instructions_loop
    
    GET_CHILD:
     	LDRH R8, [R10, #34]	;@ get Objtable
    	LSL R0, R0, #7
    	ADD R0, R0, #10
    	ADD R0, R0, R8
    	LDRH R0, [R7, R0]
    	REV16 R0, R0
    	BL memory_read
    	BL store_register_operand
    	CMP R0, #0
    		BNE branch
    BL memory_read
    BL check_if_long_branch
    B decode_instructions_loop

    store_register_operand:
	CMP R8, #0xF
		BHI global_register_operand_3
	CMP R8, #0
		BEQ zstack_operand_3
		BNE local_register_operand_3
	global_register_operand_3:
	SUB R8, R8, #16
	LSL R8, R8, #1 		;@This is A
	STRB R11, [R10, #7]
	LDRH R11, [R10, #25]
	ADD R11, R8, R11
	REV16 R0, R0
	STRH R0 ,[R7, R11]
	MOV R15, R14

	zstack_operand_3:
	LDR R9, =Zstack
	STRH R0, [R9, R5]   ;@ store the result into the stack
	ADD R5, R5, #2
	;@ need to increment the 20th local register
	LSL R9, R6, #6                 ;@ multiply nesting depth by 64--B
	ADD R9, R9, #40                 ;@ add A and B giving you C the offset
	MOV R11, R9
	LDRH R9 ,[R12, R9]        ;@ add c to the location of your zprodedure local zregister, this is the higher order byte
	ADD R9, R9, #1                ;@ add 1 to the value in the register
	STRH R9, [R12, R11]        ;@ store in the new value
	MOV R15, R14

    local_register_operand_3:
	SUB R8, R8, #1
	LSL R8, R8, #1 		;@ This is A
	LSL R9, R6, #6 		;@ This is B
	ADD R9, R9, R8 		;@ This is the offset of the zregister
	STRH R0, [R12, R9]
    MOV R15, R14
    
    GET_PARENT:
    ;@ parent_field = Zmembase + Objtable + (object index * 14) + 6
    LDRH R8, [R10, #34]	;@ get Objtable
    LSL R0, R0, #7
    ADD R0, R0, #6
    ADD R0, R0, R8
    LDRH R9, [R7, R0]	;@ fetch the parent
    REV16 R9, R9
    B get_location_of_register
    
    GET_PROP_LEN:
    ;@ TBD
    B determine_crash_counter
    
    INC:
    MOV R8, R0
    MOV R11, #1
	CMP R8, #0
		BLEQ zstack_operand
		BEQ skip_inc
	CMP R8, #0xF
		BLLS local_register_operand ;@ branch if less than
		BLHI global_register_operand_fetch
	skip_inc:
    ADD R9, R1, #1
    MOV R8, R0
    MOV R11, #1
	CMP R8, #0
		BEQ get_zstack_location
	CMP R8, #0xF
		BLS local_register_location ;@ branch if less than
		BHI global_register_location

    DEC:
    	MOV R8, R0
    MOV R11, #1
	CMP R8, #0
		BLEQ zstack_operand
		BEQ skip_dec
	CMP R8, #0xF
		BLLS local_register_operand ;@ branch if less than
		BLHI global_register_operand_fetch
	skip_dec:
    SUB R9, R1, #1
    MOV R8, R0
    MOV R11, #1
	CMP R8, #0
		BEQ get_zstack_location
	CMP R8, #0xF
		BLS local_register_location ;@ branch if less than
		BHI global_register_location

    global_register_operand_fetch:
    SUB R8, R8, #16
	LSL R8, R8, #1 		;@This is A
	LDRH R11, [R10, #25]
	ADD R11, R8, R11
	LDRH R9 ,[R7, R11]
	REV16 R9, R9
	MOV R1, R9
    MOV R15, R14

    PRINT_ADDR:
    grab_next_two_bytes_3:
    BL memory_read_PRINT_ADDR
    LDR R9, =#0x80		;@ check if the top bit is the stop bit
    AND R9, R8, R9		;@ extract the possible stop bit
    STRB R9, [R10, #8]
    LSL R11, R8, #8	;@ shift most significant bits
    BL memory_read_PRINT_ADDR
    ORR R11, R8, R11	;@ concatenate the least significant byte to most significant
    ;@ first character
    LDR R9, =#0x7C00
    AND R9, R9, R11
    LSR R9, R9, #10
    BL find_the_character
    BL send_to_UART
    ;@ second character
    LDR R9, =#0x3E0
    AND R9, R9, R11
    LSR R9, R9, #5
    BL find_the_character
    BL send_to_UART
    ;@ third character
    LDR R9, =#0x1F
    AND R9, R9, R11
    BL find_the_character
    BL send_to_UART
    LDRB R9, [R10, #8]
    CMP R9, #0
    	BEQ grab_next_two_bytes_3
    B decode_instructions_loop

    memory_read_PRINT_ADDR:
    LDRB R8, [R7, R0]	;@ R4 is holding the value of ZPC, location of first instruction
    ADD R0, R0, #1		;@ increment the ZPC by one
    MOV R15, R14

    CALL_1S:
    MOV R11, #1
    STRB R11, [R10, #4]
    MOV R11, #0
    B calls
    
    REMOVE_OBJ:
    ;@ THIS IS LONG
    B determine_crash_counter
    
    PRINT_OBJ:
    B decode_instructions_loop
    
    RET:
    	MOV R11, R0
    B RETURN
    
    JUMP:
    LDRB R9, [R10, #23]
    	CMP R9, #0
    	MOV R9, R0
    	BLEQ sign_extend_16_bit
    SUB R9, R9, #2				;@ sub two from operand
    ADD R4, R4, R9
    B determine_crash_counter
    
    PRINT_PADDR:
    LSL R0, R0, #2		;@ multiply the operand by four
    grab_next_two_bytes_4:
    BL memory_read_PRINT_ADDR
    LDR R9, =#0x80		;@ check if the top bit is the stop bit
    AND R9, R8, R9		;@ extract the possible stop bit
    STRB R9, [R10, #8]
    LSL R11, R8, #8	;@ shift most significant bits
    BL memory_read_PRINT_ADDR
    ORR R11, R8, R11	;@ concatenate the least significant byte to most significant
    ;@ first character
    LDR R9, =#0x7C00
    AND R9, R9, R11
    LSR R9, R9, #10
    BL find_the_character
    BL send_to_UART
    ;@ second character
    LDR R9, =#0x3E0
    AND R9, R9, R11
    LSR R9, R9, #5
    BL find_the_character
    BL send_to_UART
    ;@ third character
    LDR R9, =#0x1F
    AND R9, R9, R11
    BL find_the_character
    BL send_to_UART
    LDRB R9, [R10, #8]
    CMP R9, #0
    	BEQ grab_next_two_bytes_4
    B decode_instructions_loop
    
    CALL_1N:
    MOV R11, #0
    STRB R11, [R10, #4]
    B calls
