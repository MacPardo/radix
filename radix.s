        .data
txt_menu:       "\nMenu\n1 Inserir\n2 Remover\n3 Buscar\n4 Ordenar\n5 Exibir\n6 Sair\nOpcao: "
txt_insere:     "\nValor a inserir: "
        .text
main:
        li   $s0, 0     #s0 aponta para o inicio da lista, inicialmente null
mostra_menu:    
        la   $a0, txt_menu
        li   $v0, 4
        syscall
        li   $v0, 5
        syscall
        li   $t0, 1
        beq  $v0, $t0, inserir
        li   $t0, 2
        beq  $v0, $t0, remover
        li   $t0, 3
        beq  $v0, $t0, buscar
        li   $t0, 4
        beq  $v0, $t0, ordenar
        li   $t0, 5
        beq  $v0, $t0, exibir

        #se nao foi nenhuma dessas opcoes, sai do programa
        li   $v0, 10
        syscall

inserir:        
        li   $v0, 5
        la   $a0, txt_insere
        syscall
        li   $v0, 4
        syscall
        move $a0, $v0
