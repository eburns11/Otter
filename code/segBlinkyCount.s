.data
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

.text
init:    li    s0,0x11008004	#buttons address
         li    s1,0x1100C004	#segs address
         li    s2,0x1100C008	#anodes address
         la    s3,sseg		#sseg LUT
         li    s4,0x7		#anode 1 on
         li    s5,0xF		#anodes off

main:    lw    t0,0(s0)	#get button data
         andi  t0,t0,0x1	#mask for button U17
         bne   t0,x0,go	#if button, go

         lbu   t0,0(s3)	#load seg 0
         sw    t0,0(s1)	#set seg to 0
         call  blink		#blink

         j     main

go:      li    t0,0x1		#big loop count
         li    a1,0x1		#incrementer
         li    t2,0x9		#end num
         mv    t3,x0		#loop count
         
useg:    add   t4,s3,t0	#update segs
         lbu   t5,0(t4)	#get seg data
         sw    t5,0(s1)	#send update

gloop:   call  blink		#blink
         addi  t3,t3,0x1	#increment loop count
         beq   t3,t0,gcheck	#when little loop is done, check status
         j     gloop

gcheck:  bne   t2,t0,gadmin	#if big loop not done, go to loop admin
         li    t5,-1		#load -1 for comparison
         beq   a1,t5,main	#if big loop done and was decreasing, back to main
         mv    a1,t5		#else change incrementer to -1
         li    t2,0x1		#change end to 1

gadmin:  add   t0,t0,a1	#increment big loop
         mv    t3,x0		#reset loop count
         j     useg

blink:   mv    s11,ra		#save ra
         #(no need for a stack in this implementation)
         sw    s4,0(s2)	#turn anode on
         call  delay
         sw    s5,0(s2)	#turn anode off
         call  delay
         mv    ra,s11		#restore ra
         ret

delay:   li    t6,0x7FFFF	#delay count
dloop:   beq   t6,x0,done	#delay break
         addi  t6,t6,-1	#delay decrement
         j     dloop
done:    ret
