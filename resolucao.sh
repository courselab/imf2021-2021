#!/bin/bash

clean(){
    printf "Limpando temps...\n"
    if [ -d "temps" ]
    then
        rm -rf temps Makefile *.png *.bmp *.raw cypher_fix.o *.S *.bin unlock.c unlock.o
    fi
    sleep 0.7s
    printf "Limpo com sucesso!\n"
    mkdir temps
}

step1(){
    printf "PASSO 1: "
    printf "Vamos inspecionar os arquivos 'decode.o' e 'libcypher.so' \n"
    hexdump -Cv decode.o > temps/decode.txt
    hexdump -Cv libcypher.so > temps/cypher.txt
    printf "Arquivo criado com sucesso!\n"
    read -e -p "Abrir o arquivo decode? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano temps/decode.txt
    fi
    sleep 0.5s
    printf "Daqui, retiramos uma informacao de uso do programa:\n"
    printf "Temos varias informacao para usage, todavia, conseguimos notar que ao usar '-h', temos acesso as opcoes disponiveis.\n"
    printf "Guardaremos isso para mais tarde...\n"
    sleep 0.5
    read -e -p "Abrir o arquivo cypher? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano temps/cypher.txt
    fi
    sleep 0.5s
    printf "Podemos notar que tratam-se de arquivos ELF...\n"
    mv temps/decode.txt temps/decode.elf
    mv temps/cypher.txt temps/cypher.elf
    printf "Arquivos renomeados com sucesso para 'decode.elf' e 'cypher.elf'! Verificar caso haja necessidade.\n"
    sleep 0.5s
}

step2(){
    printf "\n\nPASSO 2: "
    printf "Realizando uma inspecao de informacoes do elf no arquivo .o ... \n"
    sleep 1
    readelf -h decode.o > temps/decode_info.txt
    printf "Inspeção realizada com sucesso!\n"
    read -e -p "Abrir o arquivo? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano temps/decode_info.txt
    fi
    sleep 0.5s
    printf "Certo. Sabemos que se trata de um ELF32 e que foi compilado em um sistema Unix-like.\n"
    sleep 0.2s
    printf "Verificando a biblioteca dinamica distribuida juntamente com o '.o'...\n"
    readelf -h libcypher.so > temps/cypher_info.txt
    sleep 1
    printf "Inspeção realizada com sucesso!\n"
    read -e -p "Abrir o arquivo? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano temps/cypher_info.txt
    fi
    sleep 0.5s
    printf "Certo. Verificamos tambem que a libcypher foi compilada tambem em um sistema Unix-like.\n"
}

step3(){
    printf "\n\nPASSO 3: "
    printf "Partimos para a compilacao do programa.\n"
    printf "Instale a gcc-multilib caso nao esteja instalada... Para sistemas Debian-based:\n"
    echo "sudo apt install gcc-multilib"
    sleep 0.1s
    read -e -p "Continuar? (0/1): " -i "1" ver
    if [ $ver -eq 0 ]
    then
        exit
    fi
    sleep 0.5s
    printf "Criando arquivo Makefile..."
    touch Makefile
    printf "Criando comandos do Makefile..."
    printf "decode: decode.o libcypher.so\n\tgcc -m32 decode.o -L. -lcypher -o decode.bin\n\n" > Makefile
    printf "run: decode\n\tLD_LIBRARY_PATH=. ./decode.bin\n\n" >> Makefile
    printf "clean:\n\trm -f decode.bin\n\n" >> Makefile
    sleep 0.5s
    printf "Criado com sucesso!\n"
    read -e -p "Abrir o Makefile? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano Makefile
    fi
    sleep 0.5s
}

step4(){
    make clean
    make
    make run
    sleep 0.6s
    printf "Observa-se que sem o conhecimento da chave, nao conseguiremos executar adquadamente.\n"
    printf "Tentaremos entao alterar a chamada feita a unlock() contida na 'libcypher.so' de um modo nao invasivo...\n"
    printf "Criamos um segundo arquivo .c que contem um funcao unlock() e linkamos primeiro esse novo arquivo de forma ao LD utilizar esse novo unlock.\n"
    sleep 1
    printf "Criando 'unlock.c'...\n"
    touch unlock.c
    printf "void unlock(){\n}" > unlock.c
    sleep 0.5
    printf "Criado com sucesso!\n"
    read -e -p "Abrir 'unlock.c'? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano unlock.c
    fi
    sleep 0.5s
    printf "Alteramos entao o Makefile para acrescentar unlock.c a construcao do executavel...\n"
    printf "decode: unlock.o decode.o libcypher.so\n\tgcc -m32 decode.o unlock.o -L. -lcypher -o decode.bin\n\n" > Makefile
    printf "unlock.o: unlock.c\n\tgcc -c -m32 $< -o unlock.o\n\n" >> Makefile
    printf "run: decode\n\tLD_LIBRARY_PATH=. ./decode.bin \$(args)\n\n" >> Makefile
    printf "clean:\n\trm -f decode.bin\n\n" >> Makefile
    sleep 0.5s
    printf "Concluido!\n"
    read -e -p "Abrir 'Makefile'? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano Makefile
    fi
    sleep 0.5s
    printf "Temos agora o Makefile linkando nosso unlock.c a nosso executavel de forma a alterar a funcao unlock()!\n"
    sleep 0.5s
    printf "Observamos que, agora, conseguimos rodar o programa sem passar pela verificacao!\n"
    sleep 0.2s
}

step5(){
    printf "Como dito anteriormente, temos a flag '-h' para ajuda:\n"
    echo "make run args=-h"
    read -e -p "Prosseguir? (0/1): " -i "1" ver
    if [ $ver -eq 0 ]
    then
        exit
    fi
    make run args=-h
    sleep 1s
    printf "Observamos o uso do programa, entao, chamamos para os dois arquivos:\n"
    echo "make run args='-k ABC -d crypt*.dat crypt1.raw'"
    make run args='-k ABC -d crypt1.dat crypt1.raw'
    make run args='-k ABC -d crypt2.dat crypt2.raw'
    sleep 0.5s
    printf "Notamos um erro ao decriptografarmos crypt2. Todavia, ignoraremos por hora, apenas descobrindo o conteudo de crypt1 por enquanto.\n"
    printf "Inspecionamos agora os arquivos utilizando o comando 'file'...\n"
    sleep 3
    file crypt1.raw
    file crypt2.raw
    printf "Descobrimos que crypt1 eh uma imagem '.png' e crypt2 seria uma imagem '.bmp' se tudo corresse bem.\n"
    printf "Alteramos o formato de crypt1...\n"
    mv crypt1.raw crypt1.png
    sleep 0.5s
    printf "Alterado com sucesso!\n"
    read -e -p "Prosseguir? (0/1): " -i "1" ver
    if [ $ver -eq 0 ]
    then
        exit
    fi
    printf "Utilize algum visualizador de imagem para conferir o resultado!\n"
    sleep 2
}

step6(){
    printf "Vamos agora eliminar o erro que causou o segfault.\n"
    sleep 1
    printf "Descobrimos atraves de uma analise em cima do '.o' que o problema se encontra em uma chamada para enderecos. Alteraremos, entao, a funcao change contida em libcypher.\n"
    sleep 5
    touch cypher_fix.S
    echo ";Incluir .text e .global change. Formatar o trecho para 'change:' e trocar o retorno para \$0x10. Remover o call que popa em ax." > cypher_fix.S
    objdump --disassemble=change --no-show-raw-insn libcypher.so | awk -F: '{print $2}' >> cypher_fix.S
    nano cypher_fix.S
    printf "Alteramos entao o Makefile para acrescentar cypher_fix.S a construcao do executavel...\n"
    printf "decode: cypher_fix.o unlock.o decode.o libcypher.so\n\tgcc -m32 cypher_fix.o decode.o unlock.o -L. -lcypher -o decode.bin\n\n" > Makefile
    printf "unlock.o: unlock.c\n\tgcc -c -m32 $< -o unlock.o\n\n" >> Makefile
    printf "cypher_fix.o: cypher_fix.S\n\tas -32 $< -o cypher_fix.o\n\n" >> Makefile
    printf "run: decode\n\tLD_LIBRARY_PATH=. ./decode.bin \$(args)\n\n" >> Makefile
    printf "clean:\n\trm -f decode.bin\n\n" >> Makefile
    printf "tar:\n\ttar zcvf decode.tar.gz Makefile cypher_fix.S unlock.c decode.o libcypher.so\n\n" >> Makefile
    sleep 0.5s
    printf "Concluido!\n"
    read -e -p "Abrir 'Makefile'? (0/1): " -i "1" ver
    if [ $ver -eq 1 ]
    then
        nano Makefile
    fi
    sleep 0.5s
    printf "Rebuildando arquivos..\n"
    make
    sleep 0.7s
    printf "Finalizado!\n"
    sleep 0.5s
    printf "make run args='-k ABC -d crypt2.dat temp.bmp\n'"
    make run args='-k ABC -d crypt2.dat crypt2.bmp'
    printf "Finalizado!\n"
}

clean #Limpando arquivos temporarios anteriores
step1 #Realizando inspecao inicial
step2 #Obtendo informacoes dos elfs
step3 #Criando o Makefile e suas rotinas
step4 #Rodando o make e verificando o que devera ser feito
step5 #Decriptografando os arquivos. Todavia, falha para crypt2
step6 #Alterando a funcao change(), rebuildando e construindo
