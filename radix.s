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
txt_debug:      .asciiz "\nDebug\n"
radix_aux:      .space  4000
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

        bne  $s0, $t1, nao_primeiro   #se o elemento a ser removido eh o primeiro
        lw   $s0, 8 ($t1) #tem que atualizar s0 como t1->prox
nao_primeiro:

        lw   $t2, 4 ($t1) #t2 aponta para o anterior
        lw   $t3, 8 ($t1) #t3 aponta para o proximo


        #fazer reaponteirametno

        #if t1->prev != NULL:
        #    t1->prev->next = t1->next
        beqz $t2, prev_null
        sw   $t3, 8 ($t2)
prev_null:      

        #if t1->next != NULL:
        #    t1->next->prev = t1->prev
        beqz $t3, next_null
        sw   $t2, 4 ($t3)
next_null:      

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
        beqz $s0, menu #se a lista eh vazia nao tem que ordenar
        #t0 eh valor do elemento atual
        #t1 eh ponteiro p/ elemento atual
        #t2 eh o maior valor
        #t3 eh o tamanho da lista
        move $t1, $s0 #t1 esta apontando para o inicio da lista
        lw   $t2, 0 ($s0) #t2 (max) eh o primeiro valor inicialmente
        move $t3, $zero #t3 (tamanho_lista) eh inicialmente zero
ord_loop0_beg:          #loop para encontrar o valor maximo e o tamanho da lista
        beqz $t1, ord_loop0_end #se o elemento atual eh NULL, sai do loop
        lw   $t0, 0 ($t1)
        addi $t3, $t3, 1  #tamanho_lista++
        lw   $t1, 8 ($t1) #t1 = t1->next #prepara t1 para a proxima iteracao

        slt  $t7, $t2, $t0 #se max < elemento_atual, t7 = 1, senao t7 = 0
        
        #t7 vai ser 1 quando tem que atualizar max
        beqz $t7, ord_loop0_beg #se nao tem que atualizar max vai para o comeco do loop
        move $t2, $t0 #atualiza max como elemento_atual
        
        j    ord_loop0_beg
ord_loop0_end:

        #agora t2 eh o maior valor e t3 eh o tamanho da lista
        
        la   $a0, txt_linha
        li   $v0, 4
        syscall         #print "\n"

        move $a0, $t2
        li   $v0, 1
        syscall

        la   $a0, txt_linha
        li   $v0, 4
        syscall         #print "\n"

        move $a0, $t3
        li   $v0, 1
        syscall

        j    menu
