.syntax unified
.global main
.extern init_leds, write_row_pins, write_column_pins, delay
.include "src/symbols.S"

@ Sound and GPIO related constants
.equ BUTTON_A_PIN, 14       @ micro:bit button A is on pin 14
.equ BUTTON_B_PIN, 23       @ micro:bit button B is on pin 23
.equ GPIO_P0,           0x50000000
.equ GPIO_PX_PIN_CNF0,  0x700
.equ GPIO_PX_PIN_CNF14, 0x738
.equ GPIO_PX_PIN_CNF23, 0x75C
.equ GPIO_PX_IN,        0x510
.equ GPIO_PX_OUTSET,    0x508
.equ GPIO_PX_OUTCLR,    0x50C

@ Sound related constants
.equ FREQ_C,            262
.equ FREQ_D,            294
.equ FREQ_E,            330
.equ DELAY_C,           6100
.equ DELAY_D,           5450
.equ DELAY_E,           4850
.equ TOGGLE_C,          65
.equ TOGGLE_D,          73
.equ TOGGLE_E,          83
.equ SILENT_DELAY,      793000*2

@ Patterns for all digits 0-9, colon and alarm icon, each pattern has 5 rows
.data
.align 2

@ Alarm time settings
alarm_time:
    .word 23  @ Alarm hours (0-23)
    .word 46  @ Alarm minutes (0-59)
    .word 0   @ Alarm active flag (0 = off, 1 = on)

@ Alarm settings
alarm_settings:
    .word 67  @ Max alarm iterations (changed from 60 seconds to 10 iterations)
    .word 0   @ Alarm is currently sounding flag (0 = silent, 1 = sounding)
    .word 0   @ Alarm iterations counter (changed from seconds to iterations)
    .word 0   @ Alarm is in snooze mode (0 = not snoozed, 1 = snoozed)
    .word 0   @ Snooze time counter in seconds (counts up to 5 minutes = 300 seconds)

@ Digit patterns for display
digit_patterns:
    @ Digit 0
    .word 0b01110  @ Row 0: . X X X .
    .word 0b10001  @ Row 1: X . . . X
    .word 0b10001  @ Row 2: X . . . X
    .word 0b10001  @ Row 3: X . . . X
    .word 0b01110  @ Row 4: . X X X .

    @ Digit 1
    .word 0b00100  @ Row 0: . . X . .
    .word 0b00110  @ Row 1: . X X . .
    .word 0b00100  @ Row 2: . . X . .
    .word 0b00100  @ Row 3: . . X . .
    .word 0b01110  @ Row 4: . X X X .

    @ Digit 2
    .word 0b01110  @ Row 0: . X X X .
    .word 0b10001  @ Row 1: X . . . X
    .word 0b01000  @ Row 2: . . . X .
    .word 0b00100  @ Row 3: . . X . .
    .word 0b11111  @ Row 4: X X X X X

    @ Digit 3
    .word 0b01110  @ Row 0: . X X X .
    .word 0b10001  @ Row 1: X . . . X
    .word 0b01100  @ Row 2: . . X X .
    .word 0b10001  @ Row 3: X . . . X
    .word 0b01110  @ Row 4: . X X X .

    @ Digit 4
    .word 0b01000  @ Row 0: . . . X .
    .word 0b01100  @ Row 1: . . X X .
    .word 0b01010  @ Row 2: . X . X .
    .word 0b11111  @ Row 3: X X X X X
    .word 0b01000  @ Row 4: . . . X .

    @ Digit 5
    .word 0b11111  @ Row 0: X X X X X
    .word 0b00001  @ Row 1: X . . . .
    .word 0b11110  @ Row 2: X X X X .
    .word 0b10000  @ Row 3: . . . . X
    .word 0b11111  @ Row 4: X X X X .

    @ Digit 6
    .word 0b01110  @ Row 0: . X X X .
    .word 0b00001  @ Row 1: X . . . .
    .word 0b01111  @ Row 2: X X X X .
    .word 0b10001  @ Row 3: X . . . X
    .word 0b01110  @ Row 4: . X X X .

    @ Digit 7
    .word 0b11111  @ Row 0: X X X X X
    .word 0b10000  @ Row 1: . . . . X
    .word 0b01000  @ Row 2: . . . X .
    .word 0b00100  @ Row 3: . . X . .
    .word 0b00010  @ Row 4: . X . . .

    @ Digit 8
    .word 0b01110  @ Row 0: . X X X .
    .word 0b10001  @ Row 1: X . . . X
    .word 0b01110  @ Row 2: . X X X .
    .word 0b10001  @ Row 3: X . . . X
    .word 0b01110  @ Row 4: . X X X .

    @ Digit 9
    .word 0b01110  @ Row 0: . X X X .
    .word 0b10001  @ Row 1: X . . . X
    .word 0b11110  @ Row 2: . X X X X
    .word 0b10000  @ Row 3: . . . . X
    .word 0b01110  @ Row 4: . X X X .

    @ Colon pattern
    .word 0b00000  @ Row 0: . . . . .
    .word 0b00100  @ Row 1: . . X . .
    .word 0b00000  @ Row 2: . . . . .
    .word 0b00100  @ Row 3: . . X . .
    .word 0b00000  @ Row 4: . . . . .

    @ Alarm icon pattern (bell shape)
    .word 0b00100  @ Row 0: . . X . .
    .word 0b01110  @ Row 1: . X X X .
    .word 0b01110  @ Row 2: . X X X .
    .word 0b01110  @ Row 3: . X X X .
    .word 0b11111  @ Row 4: X X X X X

    @ Snooze icon pattern (Z symbol)
    .word 0b11111  @ Row 0: X X X X X
    .word 0b10000  @ Row 1: . . . . X
    .word 0b01110  @ Row 2: . . X X .
    .word 0b00001  @ Row 3: X . . . .
    .word 0b11111  @ Row 4: X X X X X

@ Display durations
.align 2
display_durations:
    .word 38  @ Hours tens digit duration
    .word 38  @ Hours ones digit duration
    .word 50 @ Colon duration
    .word 38  @ Minutes tens digit duration
    .word 38  @ Minutes ones digit duration
    .word 63  @ Pause between timestamps

@ Time
.align 2
initial_time:
    .word 23  @ Initial hours (0-23)
    .word 45  @ Initial minutes (0-59)
    .word 0   @ Initial seconds (0-59)

@ Counter for repeating timestamps
.align 2
repeat_counter:
    .word 0   @ Will count from 0 to 9

@ Snooze duration in seconds (5 minutes = 300 seconds)
.align 2
snooze_duration:
    .word 12900  @ 5 minutes

.text
.type main, %function
main:
    push {r4-r11, lr}

    @ Initialize LED matrix
    bl init_leds

    @ Configure GPIO for sound output (Pin 0)
    ldr r0, =GPIO_P0
    mov r1, #1          @ Output mode
    str r1, [r0, #GPIO_PX_PIN_CNF0]

    @ Configure GPIO for button inputs
    ldr r0, =GPIO_P0
    mov r1, #0          @ Input mode
    str r1, [r0, #GPIO_PX_PIN_CNF14]  @ Button A
    str r1, [r0, #GPIO_PX_PIN_CNF23]  @ Button B

    @ Load initial timestamp
    ldr r0, =initial_time
    ldr r1, [r0, #0]    @ r1 = initial hours
    ldr r2, [r0, #4]    @ r2 = initial minutes

    @ Initialize repeat counter
    ldr r0, =repeat_counter
    mov r3, #0
    str r3, [r0]

    @ Convert hours and minutes to digits
    bl convert_time_to_digits    @ Result in r8-r11

    @ Activate alarm for testing
    ldr r0, =alarm_time
    mov r1, #1
    str r1, [r0, #8]    @ Set alarm active flag

clock_outer_loop:
    @ Check if alarm is in snooze mode
    ldr r0, =alarm_settings
    ldr r1, [r0, #12]   @ Load snooze mode flag
    cmp r1, #1
    beq handle_snooze_mode

    @ Check if alarm is currently sounding
    ldr r7, [r0, #4]    @ Load alarm sounding flag
    cmp r7, #1
    beq handle_sounding_alarm

    @ Display the current time (r8:r9:r10:r11) as hours:minutes
    @ Display hours tens digit
    mov r0, r8          @ Digit value
    ldr r1, =display_durations
    ldr r1, [r1, #0]    @ Duration
    bl display_digit_for_cycles
    bl check_buttons

    @ Display hours ones digit
    mov r0, r9
    ldr r1, =display_durations
    ldr r1, [r1, #4]
    bl display_digit_for_cycles
    bl check_buttons

    @ Display colon
    mov r0, #10         @ Colon pattern index
    ldr r1, =display_durations
    ldr r1, [r1, #8]
    bl display_digit_for_cycles
    bl check_buttons

    @ Display minutes tens digit
    mov r0, r10
    ldr r1, =display_durations
    ldr r1, [r1, #12]
    bl display_digit_for_cycles
    bl check_buttons

    @ Display minutes ones digit
    mov r0, r11
    ldr r1, =display_durations
    ldr r1, [r1, #16]
    bl display_digit_for_cycles
    bl check_buttons

    @ Pause between displays
    mov r0, #0b11111    @ Turn off all columns
    bl write_column_pins
    mov r0, #0b00000    @ Turn off all rows
    bl write_row_pins
    
    ldr r0, =display_durations
    ldr r0, [r0, #20]   @ Pause duration
    bl pause_for_cycles
    bl check_buttons

    @ Increment repeat counter
    ldr r0, =repeat_counter
    ldr r3, [r0]
    add r3, #1
    str r3, [r0]
    cmp r3, #10
    blt skip_time_update

    @ Reset repeat counter
    mov r3, #0
    str r3, [r0]

    @ Update time
    bl update_time

skip_time_update:
    b clock_outer_loop


@ Handle snooze mode
handle_snooze_mode:
    @ Show snooze icon briefly
    mov r0, #12         @ Snooze icon pattern index
    mov r1, #1          @ Just one cycle
    bl display_digit_for_cycles

    @ Increment snooze counter
    ldr r0, =alarm_settings
    ldr r1, [r0, #16]   @ Load snooze time counter
    add r1, #1          @ Increment counter
    str r1, [r0, #16]   @ Store updated counter

    @ Check if snooze time has elapsed (5 minutes)
    ldr r2, =snooze_duration
    ldr r2, [r2]        @ Load snooze duration
    cmp r1, r2
    blt skip_snooze_end

    @ Snooze time elapsed, reset snooze mode and trigger alarm again
    mov r1, #0
    str r1, [r0, #12]   @ Reset snooze mode flag
    str r1, [r0, #16]   @ Reset snooze counter
    
    @ *** NEW CODE: Update time by the snooze duration (5 minutes) ***
    @ Each 10 iterations = 1 minute, so 5 minutes = 50 iterations worth of time
    @ We'll do this by calling update_time multiple times
    
    @ Save registers we'll modify
    push {r4, lr}
    
    @ Update time 5 times (equivalent to 5 minutes)
    mov r4, #5          @ 5 minutes to add
    
update_time_loop:
    @ Advance the minute
    add r11, #1         @ Increment minutes ones digit
    cmp r11, #10
    bne next_minute
    
    @ Minutes ones digit reached 10, reset and increment tens
    mov r11, #0
    add r10, #1
    cmp r10, #6
    bne next_minute
    
    @ Minutes tens digit reached 6, reset and increment hours
    mov r10, #0
    add r9, #1          @ Increment hours ones digit
    cmp r9, #10
    bne check_hours_rollover
    
    @ Hours ones digit reached 10, reset and increment tens
    mov r9, #0
    add r8, #1
    
check_hours_rollover:
    @ Check if we've reached 24:00
    cmp r8, #2
    bne next_minute
    cmp r9, #4
    bne next_minute
    
    @ If we reached 24:00, reset to 00:00
    mov r8, #0
    mov r9, #0
    
next_minute:
    subs r4, #1         @ Decrement our minute counter
    bne update_time_loop
    
    pop {r4, lr}
    @ *** END NEW CODE ***
    
    @ Now trigger the alarm again
    mov r1, #1
    str r1, [r0, #4]    @ Set alarm sounding flag
    mov r1, #0
    str r1, [r0, #8]    @ Reset alarm iterations counter

skip_snooze_end:
    @ Continue normal clock display
    b clock_outer_loop

@ Update time and check alarm function
update_time:
    push {r4-r7, lr}

    @ Update time digits
    @ Increment seconds (simulated in this case)
    @ Update minutes first
    add r11, #1              @ Increment minutes ones digit
    cmp r11, #10
    bne time_updated         @ Skip to alarm check if no cascade needed

    @ If minutes ones reached 10, reset it and increment minutes tens
    mov r11, #0
    add r10, #1
    cmp r10, #6
    bne time_updated         @ Skip to alarm check if no cascade needed

    @ If minutes tens reached 6, reset it and increment hours
    mov r10, #0
    add r9, #1               @ Increment hours ones digit
    cmp r9, #10
    bne check_hours_limit    @ Skip if hours ones digit is still valid

    @ If hours ones reached 10, reset it and increment hours tens
    mov r9, #0
    add r8, #1

check_hours_limit:
    @ Check if we've reached 24:00
    cmp r8, #2
    bne time_updated         @ Skip to alarm check if not 2x:xx
    cmp r9, #4
    bne time_updated         @ Skip to alarm check if not 24:xx

    @ If we reached 24:00, reset to 00:00
    mov r8, #0
    mov r9, #0

time_updated:
    @ Current time is now updated. Check if it matches alarm time.
    
    @ Load alarm settings
    ldr r0, =alarm_time
    ldr r4, [r0, #0]         @ Load alarm hours (r4)
    ldr r5, [r0, #4]         @ Load alarm minutes (r5)
    ldr r6, [r0, #8]         @ Load alarm active flag (r6)

    @ Check if alarm is active
    cmp r6, #1
    bne update_time_done     @ Skip if alarm not active

    @ Check if alarm is already sounding
    ldr r7, =alarm_settings
    ldr r6, [r7, #4]         @ Load alarm sounding flag
    cmp r6, #1
    beq update_time_done     @ Skip if alarm is already sounding

    @ Check if alarm is in snooze mode
    ldr r6, [r7, #12]        @ Load snooze mode flag
    cmp r6, #1
    beq update_time_done    @ Skip if in snooze mode

    @ Calculate current hours value (r8*10 + r9)
    mov r0, r8
    mov r1, #10
    mul r0, r1
    add r0, r9               @ r0 = current hours

    @ Compare hours
    cmp r0, r4
    bne update_time_done     @ Hours don't match, exit

    @ Calculate current minutes value (r10*10 + r11)
    mov r0, r10
    mov r1, #10
    mul r0, r1
    add r0, r11              @ r0 = current minutes

    @ Compare minutes
    cmp r0, r5
    bne update_time_done     @ Minutes don't match, exit

    @ Time matches exactly, start alarm
    ldr r0, =alarm_settings
    mov r1, #1
    str r1, [r0, #4]         @ Set alarm sounding flag
    mov r1, #0
    str r1, [r0, #8]         @ Reset alarm iterations counter
    str r1, [r0, #12]        @ Ensure snooze mode is off
    str r1, [r0, #16]        @ Reset snooze counter



update_time_done:
    @ Check if alarm should trigger with the updated time
   
    pop {r4-r7, lr}
    bx lr


@ Handler for when alarm is sounding
@ Handler for when alarm is sounding
handle_sounding_alarm:
    @ Check buttons to stop or snooze alarm
    bl check_buttons_alarm
    
    @ Check if alarm iterations reached max
    ldr r0, =alarm_settings
    ldr r1, [r0, #8]    @ Load alarm iterations counter
    ldr r2, [r0, #0]    @ Load max alarm iterations
    cmp r1, r2
    bge auto_stop_alarm  @ Auto-stop alarm if iterations reached max
    
    @ Increment alarm iterations counter
    add r1, #1
    str r1, [r0, #8]
       
    @ Select tone based on counter
    and r1, #3          @ r1 = counter % 4
    cmp r1, #0
    beq play_tone_c
    cmp r1, #1
    beq play_tone_d
    cmp r1, #2
    beq play_tone_e
    b play_tone_c       @ Default to C

play_tone_c:
    mov r4, #TOGGLE_C
    ldr r5, =DELAY_C
    b play_sound

play_tone_d:
    mov r4, #TOGGLE_D
    ldr r5, =DELAY_D
    b play_sound

play_tone_e:
    mov r4, #TOGGLE_E
    ldr r5, =DELAY_E
    b play_sound

play_sound:
    @ Display alarm icon and play sound
    mov r6, #20         @ Number of display cycles
    
alarm_sound_display_loop:
    @ Display alarm icon for a cycle
    mov r0, #11         @ Alarm icon pattern index
    mov r1, #1          @ One display cycle
    bl display_digit_for_cycles
    
    @ Check buttons during display
    bl check_buttons_alarm
    
    @ Play a portion of sound
    mov r0, r4          @ Number of toggles (saved from tone selection)
    lsr r0, #2          @ About 1/4 of the toggles per display cycle
    mov r1, r5          @ Delay value (saved from tone selection)
    bl play_tone_cycles
    
    @ Continue until all display cycles complete
    subs r6, #1
    bne alarm_sound_display_loop
    
    @ Return to main loop
    b clock_outer_loop

@ Auto-stop the alarm and show a confirmation
@ Auto-stop the alarm and show a confirmation
auto_stop_alarm:
    @ Stop the alarm
    ldr r0, =alarm_settings
    mov r1, #0
    str r1, [r0, #4]    @ Clear alarm sounding flag
    str r1, [r0, #8]    @ Reset alarm iterations counter
    
    @ Display auto-stop message (checkmark)
    mov r0, #13         @ Auto-stop icon pattern index (checkmark)
    mov r1, #40         @ Show for several cycles
    bl display_digit_for_cycles
    
    @ Advance time by one minute
    @ Update minutes first
    add r11, #1         @ Increment minutes ones digit
    cmp r11, #10
    bne auto_stop_done
    
    @ If minutes ones reached 10, reset it and increment minutes tens
    mov r11, #0
    add r10, #1
    cmp r10, #6
    bne auto_stop_done
    
    @ If minutes tens reached 6, reset it and increment hours
    mov r10, #0
    add r9, #1          @ Increment hours ones digit
    cmp r9, #10
    bne auto_stop_hour_check
    
    @ If hours ones reached 10, reset it and increment hours tens
    mov r9, #0
    add r8, #1
    
auto_stop_hour_check:
    @ Check if we've reached 24:00
    cmp r8, #2
    bne auto_stop_done
    cmp r9, #4
    bne auto_stop_done
    
    @ If we reached 24:00, reset to 00:00
    mov r8, #0
    mov r9, #0

auto_stop_done:
    b clock_outer_loop

@ Play tone for specified number of cycles
@ r0 = number of toggles, r1 = delay value
play_tone_cycles:
    push {r4-r7, lr}
    mov r4, r0          @ Number of toggles
    mov r5, r1          @ Delay value
    
tone_loop:
    @ Toggle Pin 0 high
    ldr r0, =GPIO_P0
    mov r1, #1
    str r1, [r0, #GPIO_PX_OUTSET]
    
    @ Delay
    mov r0, r5
    bl delay
    
    @ Toggle Pin 0 low
    ldr r0, =GPIO_P0
    mov r1, #1
    str r1, [r0, #GPIO_PX_OUTCLR]
    
    @ Delay
    mov r0, r5
    bl delay
    
    @ Continue until all toggles done
    subs r4, #1
    bne tone_loop
    
    pop {r4-r7, lr}
    bx lr

@ Stop the alarm completely
stop_alarm:
    ldr r0, =alarm_settings
    mov r1, #0
    str r1, [r0, #4]    @ Clear alarm sounding flag
    str r1, [r0, #8]    @ Reset alarm iterations counter
    str r1, [r0, #12]   @ Clear snooze mode flag
    str r1, [r0, #16]   @ Reset snooze counter
    b clock_outer_loop

@ Activate snooze mode
activate_snooze:
    ldr r0, =alarm_settings
    mov r1, #0
    str r1, [r0, #4]    @ Clear alarm sounding flag
    str r1, [r0, #8]    @ Reset alarm iterations counter
    mov r1, #1
    str r1, [r0, #12]   @ Set snooze mode flag
    mov r1, #0
    str r1, [r0, #16]   @ Reset snooze counter
    
    @ Show snooze icon to confirm
    mov r0, #12         @ Snooze icon pattern index
    mov r1, #40         @ Show for several cycles
    bl display_digit_for_cycles
    
    b clock_outer_loop

@ Check button states for alarm setting
check_buttons:
    push {r4-r7, lr}
    
    @ Check Button A (toggle alarm on/off)
    ldr r0, =GPIO_P0
    ldr r1, [r0, #GPIO_PX_IN]
    mov r2, #1
    lsl r2, #BUTTON_A_PIN
    tst r1, r2          @ Test if button A bit is set (not pressed)
    bne check_button_b  @ Skip if button not pressed

    @ Button A pressed - toggle alarm on/off
    ldr r0, =alarm_time
    ldr r1, [r0, #8]    @ Load current alarm active flag
    eor r1, #1          @ Toggle between 0 and 1
    str r1, [r0, #8]    @ Store updated alarm active flag
    
    @ Debounce delay
    ldr r0,=#500000
    bl delay
    
check_button_b:
    @ Check Button B (adjust alarm time)
    ldr r0, =GPIO_P0
    ldr r1, [r0, #GPIO_PX_IN]
    mov r2, #1
    lsl r2, #BUTTON_B_PIN
    tst r1, r2          @ Test if button B bit is set (not pressed)
    bne check_buttons_exit  @ Skip if button not pressed

    @ Button B pressed - increment alarm time
    ldr r0, =alarm_time
    ldr r1, [r0, #0]    @ Load alarm hours
    ldr r2, [r0, #4]    @ Load alarm minutes
    
    @ Increment alarm minutes by 15
    add r2, #15
    cmp r2, #60
    blt store_alarm_time
    
    @ If minutes >= 60, wrap and increment hour
    sub r2, #60
    add r1, #1
    cmp r1, #24
    blt store_alarm_time
    
    @ If hours >= 24, wrap to 0
    mov r1, #0
    
store_alarm_time:
    @ Store updated alarm time
    str r1, [r0, #0]    @ Store hours
    str r2, [r0, #4]    @ Store minutes
    
    @ Activate alarm
    mov r1, #1
    str r1, [r0, #8]    @ Set alarm active flag
    
    @ Show alarm time briefly
    bl display_alarm_time
    
    @ Debounce delay
    ldr r0,=#500000
    bl delay

check_buttons_exit:
    pop {r4-r7, lr}
    bx lr

@ Check buttons while alarm is sounding
check_buttons_alarm:
    push {r4-r7, lr}
    
    @ Check Button A (stop alarm completely)
    ldr r0, =GPIO_P0
    ldr r1, [r0, #GPIO_PX_IN]
    mov r2, #1
    lsl r2, #BUTTON_A_PIN
    tst r1, r2
    beq alarm_button_a_pressed
    
    @ Check Button B (snooze - 5 minutes)
    mov r2, #1
    lsl r2, #BUTTON_B_PIN
    tst r1, r2
    beq alarm_button_b_pressed
    
    @ No button pressed
    pop {r4-r7, lr}
    bx lr
    
alarm_button_a_pressed:
    @ Button A pressed, stop alarm completely and advance time
    pop {r4-r7, lr}
    b stop_alarm  @ Just stop alarm, don't advance time when manually stopped
    
alarm_button_b_pressed:
    @ Button B pressed, activate snooze mode
    pop {r4-r7, lr}
    b activate_snooze

@ Display alarm time briefly
display_alarm_time:
    push {r4-r11, lr}
    
    @ Load alarm time
    ldr r0, =alarm_time
    ldr r1, [r0, #0]    @ r1 = alarm hours
    ldr r2, [r0, #4]    @ r2 = alarm minutes
    
    @ Convert to digits
    push {r1, r2}       @ Save alarm time
    bl convert_alarm_to_digits  @ Results in r4-r7
    
    @ Display alarm time for several iterations
    mov r3, #10         @ Display for 10 iterations
    
alarm_time_display_iter:
    @ Display alarm icon
    mov r0, #11         @ Alarm icon index
    mov r1, #30         @ Duration
    bl display_digit_for_cycles
    
    @ Display hours tens digit
    mov r0, r4          @ Hours tens
    mov r1, #55         @ Duration
    bl display_digit_for_cycles
    
    @ Display hours ones digit
    mov r0, r5          @ Hours ones
    mov r1, #55         @ Duration
    bl display_digit_for_cycles
    
    @ Display colon
    mov r0, #10         @ Colon index
    mov r1, #65         @ Duration
    bl display_digit_for_cycles
    
    @ Display minutes tens digit
    mov r0, r6          @ Minutes tens
    mov r1, #55         @ Duration
    bl display_digit_for_cycles
    
    @ Display minutes ones digit
    mov r0, r7          @ Minutes ones
    mov r1, #55         @ Duration
    bl display_digit_for_cycles
    
    @ Pause between iterations
    mov r0, #0          @ Clear display
    bl write_column_pins
    mov r0, #0
    bl write_row_pins
    
    ldr r0,=#219360
    bl delay
    
    @ Continue loop
    subs r3, #1
    bne alarm_time_display_iter
    
    pop {r1, r2}        @ Restore original alarm time values
    pop {r4-r11, lr}
    bx lr

@ Convert current time to digits (returns in r8-r11)

convert_time_to_digits:
    push {r4-r7, lr}
    
    @ Convert hours to digits
    mov r4, r1          @ r4 = hours
    mov r5, #10
    udiv r8, r4, r5     @ r8 = hours / 10 (tens digit)
    mul r6, r8, r5      @ r6 = tens digit * 10
    sub r9, r4, r6      @ r9 = hours % 10 (ones digit)
    
    @ Convert minutes to digits
    mov r4, r2          @ r4 = minutes
    mov r5, #10
    udiv r10, r4, r5    @ r10 = minutes / 10 (tens digit)
    mul r6, r10, r5     @ r6 = tens digit * 10
    sub r11, r4, r6     @ r11 = minutes % 10 (ones digit)
    
    pop {r4-r7, lr}
    bx lr

@ Convert alarm time to digits (returns in r4-r7)
convert_alarm_to_digits:
    push {r8, r9, lr}
    
    @ Convert hours to digits

    mov r4, r1          @ r4 = alarm hours
    mov r8, #10
    udiv r5, r4, r8     @ r5 = hours / 10 (tens digit)
    mul r9, r5, r8
    sub r6, r4, r9      @ r6 = hours % 10 (ones digit)
    
    @ Shift results to output registers
    mov r4, r5          @ r4 = hours tens
    mov r5, r6          @ r5 = hours ones
    
    @ Convert minutes to digits
    mov r6, r2          @ r6 = alarm minutes
    mov r8, #10
    udiv r7, r6, r8     @ r7 = minutes / 10 (tens digit)
    mul r9, r7, r8
    sub r8, r6, r9      @ r8 = minutes % 10 (ones digit)
    
    @ Shift results to output registers
    mov r6, r7          @ r6 = minutes tens
    mov r7, r8          @ r7 = minutes ones
    
    pop {r8, r9, lr}
    bx lr

@ Display a digit for a number of cycles
@ r0 = digit (0-9, 10=colon, 11=alarm, 12=snooze)
@ r1 = number of cycles
display_digit_for_cycles:
    push {r4-r7, lr}
    mov r4, r0          @ r4 = digit
    mov r5, r1          @ r5 = number of cycles
    
digit_display_loop:
    @ Display each row of the digit
    mov r6, #0          @ Row counter
    
digit_row_loop:
    @ Turn off display
    mov r0, #0b11111
    bl write_column_pins
    mov r0, #0b00000
    bl write_row_pins
    
    @ Calculate pattern offset
    mov r0, r4          @ Digit index
    mov r1, #5
    mul r0, r1          @ digit * 5
    add r0, r6          @ digit * 5 + row
    lsl r0, #2          @ (digit * 5 + row) * 4
    
    @ Load pattern
    ldr r7, =digit_patterns
    ldr r7, [r7, r0]    @ Load column pattern
    
    @ Activate row
    mov r0, #1
    lsl r0, r6
    bl write_row_pins
    
    @ Set columns
    mvn r0, r7
    and r0, #0b11111
    bl write_column_pins
    
    @ Row delay
    mov r0, #31936
    bl delay
    
    @ Next row
    add r6, #1
    cmp r6, #5
    bne digit_row_loop
    
    @ Count down cycles
    subs r5, #1
    bne digit_display_loop
    
    pop {r4-r7, lr}
    bx lr

@ Pause for a number of cycles
@ r0 = number of cycles
pause_for_cycles:
    push {r4, lr}
    mov r4, r0          @ r4 = cycle count
    
pause_cycle_loop:
    ldr r0,=219360
    bl delay
    subs r4, #1
    bne pause_cycle_loop
    
    pop {r4, lr}
    bx lr

.end