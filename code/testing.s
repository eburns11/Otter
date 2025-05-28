.text
init:	li	s1,0x1100C004	#segs address
	li	s2,0x1100C008	#anodes address
	li	s3,0x1100C000  #leds address
	li	s4,0x7		#anode 1 on
	li	s5,0xF		#anodes off

main:	li	t0,0x3		#load seg 0
	sw	t0,0(s1)	#set seg to 0
	sw	s5,0(s2)
	li	t3,0x24
	sw	t3,0(s3)

die:	nop
	j	die