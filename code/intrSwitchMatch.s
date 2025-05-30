.data
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

.text
init:	la	s0,ISR			#get ISR address
	csrrw	zero,mtvec,s0		#put ISR into mtvec
	
	la	s0,sseg			#sseg LUT address
	li	s1,0x1100C008		#anodes io address
	li	s2,0x1100C004		#segment io address
	
	li	s3,0x7			#load for anodes
	sw	s3,0(s1)		#turn off all but first display
	lbu	s3,0(s0)		#get LUT zero
	sw	s3,0(s2)		#set the display to zero
	
	li	s3,0x1100C000		#LEDS io address
	li	s4,0x11008000		#switches io address
	
	mv	a0,zero			#count 1s digit
	mv	a1,zero			#count 10s digit
	li	a2,0x1			#led position
	
	sw	a2,0(s3)		#set the first led
	
	li	s4,0x7			#display 1 on
	li	s5,0xB			#display 2 on
	li	s6,0xF			#all displays off
	
	li	t0,0x8			#mie unmask bit
	csrrs	zero,mstatus,t0		#enable interrupts
		
main:	sw	s6,0(s1)		#turn off all displays
ones:	add	a3,s0,a0		#get LUT address for 1s
	lbu	a3,0(a3)		#get LUT value
	sw	a3,0(s2)		#set 1s seg
	sw	s4,0(s1)		#turn on 1s seg
	call	delay
	
	csrrs	t0,mstatus,zero
	sw	t0,0(s3)
	
	sw	s6,0(s1)		#turn off all displays
	beq	a1,x0,blank		#blank leading zero
tens:	add	a3,s0,a1		#get LUT address for 10s
	lbu	a3,0(a3)		#get LUT value
	sw	a3,0(s2)		#set 10s seg
	sw	s5,0(s1)		#turn on 10s seg
blank:	call	delay

	j	main			#endless loop

delay:	li	a3,0xFFF		#loop count
dloop:	beq	a3,zero,ddone		#if loop done
	addi	a3,a3,-0x1		#decrement loop count
	j	dloop
ddone:	ret

ISR:	lw	t0,0(s4)		#get switch status
	and	t0,t0,a2		#compare switch and led
	beq	t0,zero,led		#skip adding if nothing

count:	addi	a0,a0,0x1		#increase ones
	li	t0,0xA			#max BCD value
	bltu	a0,t0,led		#if no carry, move on
	
	mv	a0,zero			#else, zero the ones
	addi	a1,a1,0x1		#carry to the tens
	bltu	a1,t0,led		#if no carry, move on
	
	mv	a1,zero			#else, zero the tens

led:	slli	a2,a2,0x1		#shift the led position
	li	t0,0x10000		#led overflow value
	bltu	a2,t0,idone		#if not overflowing, done
	li	a2,0x1			#else, reset to first spot
	sw	a2,0(s3)		#set

idone:	mret
