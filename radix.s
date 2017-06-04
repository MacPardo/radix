        .data
txt_menu:       "\nMenu"
        .text
        la $a0, txt_menu
        li $v0, 4
        syscall
        li $v0, 5
        syscall
