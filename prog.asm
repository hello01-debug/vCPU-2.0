#ruledef
{
    m r{index}, {value} => 0x06 @ le(index`8) @ le(value`32)
    mi => 0x08
    mtsr => 0x0F
    j r{index} => 0x30 @ index`8
    m {addr}, r{index} => 0x11 @ le(addr`32) @ index`8
    invt => 0x32
    umi => 0x09
    int {int_num} => 0x13 @ int_num`8
    pop r{index} => 0x18 @ index`8
    push {imm} => 0x17 @ le(imm`32)
    push r{index} => 0x16 @ index`8
    iret => 0x29
    hlt => 0x31
    cmp r{index}, {imm} => 0x20 @ index`8 @ le(imm`32)
    j {addr} => 0x24 @ le(addr`32)
    m r{index}, [{addr}] => 0x12 @ index`8 @ le(addr`32)
    je {addr} => 0x25 @ le(addr`32)
    m8 r{index}, [{addr}] => 0x14 @ index`8 @ le(addr`32)
}

PAGE_ADDR = 0xC0000000 >> 22
USER_PAGE_ADDR = 0 >> 22

start:
	mi
	m r0, 1
	m r1, page_tables
	mtsr ; Write the address of our page tables to SR1
	m r0, 0
	m r1, 1
	mtsr ; Enable paging
	m r0, higher_half+0xC0000000
	j r0 ; Long jump to higher half memory
higher_half: ; 0xC0000023
	m r31, stack_top+0xC0000000
	m r30, stack_bottom+0xC0000000 ; Set up stack
    m r2, 0
    m page_tables, r2 ; Unmap the lower 4 MiB
    m r2, 0x00001F05 ; Map 0x00000000 to 0x00001F00 (For usermode programs)
    m page_tables+0xC0000000, r2
    m r0, halt+0xC0000000
halt:
    j r0

	
page_tables:
#d8 5
#d8 0
#d8 0
#d8 0
#addr page_tables+(PAGE_ADDR*4)
#d8 5
#d8 0
#d8 0
#d8 0

stack_bottom:
#addr stack_bottom+0x500
stack_top:
#d8 0