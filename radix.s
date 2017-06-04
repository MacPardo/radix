        .data
txt_espaco:     .asciiz " "
txt_linha:      .asciiz "\n"
txt_menu:       .asciiz "\nMenu\n1 Inserir\n2 Remover\n3 Buscar\n4 Ordenar\n5 Exibir\n6 Sair\nOpcao: "
txt_insere:     .asciiz "\nValor a inserir: "
txt_buscar:     .asciiz "\nValor a buscar: "
txt_existe:     .asciiz "\nO elemento existe!\n"
txt_nao_existe: .asciiz "\nO elemento nao existe!\n"
txt_vazia:      .asciiz "\nLista vazia!\n"
txt_remover:    .asciiz "\nElemento a remover: "
        .text
main:
        li   $s0, 0     #s0 aponta para o inicio da lista, inicialmente NULL
menu:    
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
        beq  $v0, $t0, print

        #se nao foi nenhuma dessas opcoes, sai do programa
        li   $v0, 10
        syscall
#FIM DO MENU

inserir:        
        li   $v0, 4
        la   $a0, txt_insere
        syscall         #print txt_insere
        li   $v0, 5
        syscall         #le valor a inserir
        move $t0, $v0   #t0 eh o valor a inserir
        beqz $s0, inserir_primeiro #se a lista eh vazia, insere o primeiro elemento

        #se nao, insere sempre no final da lista
        move $t1, $s0   #t1 eh o valor atual

        #t1 tem que apontar para o elemento cujo proximo elemento eh NULL
ins_loop_beg:   
        lw   $t2, 8 ($t1) #t2 aponta para t1->prox
        beqz $t2, ins_loop_end #se t1->prox == NULL, sai do loop

        move $t1, $t2   #se nao, t1 = t1->prox
        j    ins_loop_beg
ins_loop_end:   
        #agora, $t1 aponta para o ultimo elemento

        li   $a0, 12
        li   $v0, 9
        syscall         #alocar memoria para o novo elemento

        #v0 aponta para novo elemento

        sw   $v0, 8 ($t1) #t1->prox = v0
        sw   $t0, 0 ($v0) #valor do novo elemento eh t0
        sw   $t1, 4 ($v0) #v0->ant = $t1
        sw   $zero, 8 ($v0) #v0->prox = NULL

        j    menu

inserir_primeiro:       
        li   $a0, 12
        li   $v0, 9
        syscall         #aloca 12 bytes de memoria
        move $s0, $v0   #s0 aponta para o comeco da lista, que nao eh mais NULL
        sw   $t0, 0 ($s0) #primeiros 4 bytes armazenam o valor
        sw   $zero, 4 ($s0) #segundos  4 bytes apontam para o anterior
        sw   $zero, 8 ($s0) #terceiros 4 bytes apontam para o proximo
        j    menu

#FIM DA INSERCAO


print:
        la   $a0, txt_linha
        li   $v0, 4
        syscall         #print "\n"

        beqz $s0, print_vazia #se comeco da lista eh NULL

        #se nao, printa os elementos
        move $t1, $s0   #t1 aponta para o comeco da lista
prt_loop_beg: 
        beqz $t1, prt_loop_end #se o elemento atual for NULL, termina de printar
        lw   $a0, 0 ($t1)
        li   $v0, 1
        syscall          #print t1 (elemento atual)

        la   $a0, txt_espaco
        li   $v0, 4
        syscall         #print " "

        lw   $t1, 8 ($t1) #t1 = t1->next
        j    prt_loop_beg
prt_loop_end:   
        la   $a0, txt_linha
        li   $v0, 4
        syscall         #print "\n"

        j    menu

print_vazia:
        la   $a0, txt_vazia
        li   $v0, 4
        syscall         #print txt_vazia
        j    menu

#FIM DO PRINT


remover:
        la   $a0, txt_remover
        li   $v0, 4
        syscall         #print txt_remover

        li   $v0, 5
        syscall

        #v0 eh o elemento a ser removido

        move $t1, $s0 #t1 aponta para o elemento atual
        #t1 tem que parar no elemento a ser removido

rm_loop_beg:
        beqz $t1, menu  #caso nao exista o elemento a ser removido, volta pro menu
        lw   $t0, 0 ($t1) #t0 eh o valor do elemento atual
        beq  $t0, $v0, rm_loop_end #se encontrou o valor a remover, sai do loop
        lw   $t1, 8 ($t1) #t1 = t1->next
        j    rm_loop_beg
rm_loop_end:   
        #agora, o proximo do anterior tem que ser o proximo do atual
        #e o anterior do proximo tem que ser o anterior do atual

        beq  $s0, $t1   #se o elemento a ser removido eh o primeiro
        lw   $s0, 8 ($t1) #tem que atualizar s0 como t1->prox

        lw   $t2, 4 ($t1) #t2 aponta para o anterior
        lw   $t3, 8 ($t1) #t3 aponta para o proximo

        beqz $t2, ant_null #se o anterior eh NULL
        sw   $t2, 8 ($t3)  #proximo do anterior = proximo do atual
ant_null:       

        beqz $t3, prox_null #se o proximo eh NULL
        sw   $t3, 4 ($t2)  #anterior do proximo = anterior do atual
prox_null:      

        j    menu
#FIM DA REMOCAO

buscar:
        la   $a0, txt_buscar
        li   $v0, 4
        syscall         #print txt_buscar

        li   $v0, 5
        syscall         #v0 eh o valor a buscar
        
        beqz $s0, buscar_nao_encontrou #se a lista eh vazia nao encontra elemento

        move $t1, $s0 #t1 aponta para o elemento atual
buscar_loop_beg:        
        beqz $t1, buscar_nao_encontrou #se elemento atual eh NULL, nao encontrou
        lw   $t0, 0 ($t1) #t0 eh o valor do elemento atual
        beq  $t0, $v0, buscar_encontrou #se valor do elemento atual = valor a buscar, encontrou
        lw   $t1, 8 ($t1) #t1 = t1->next
        j    buscar_loop_beg
buscar_encontrou:
        li   $v0, 4
        la   $a0, txt_existe
        syscall         #print txt_existe
        j    menu
buscar_nao_encontrou:   
        li   $v0, 4
        la   $a0, txt_nao_existe
        syscall         #print txt_nao_existe
        j    menu
#FIM DA BUSCA        

ordenar:
        j    menu
