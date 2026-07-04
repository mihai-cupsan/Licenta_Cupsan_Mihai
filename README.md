Implementarea unui procesor MIPS în variantele Single-Cycle și Pipeline
Prezentare generală
Acest repository conține codul sursă realizat pentru lucrarea de licență, care are ca obiectiv implementarea unui procesor MIPS pe 32 de biți în două variante de execuție: single-cycle și pipeline. Proiectul a fost realizat în limbajul VHDL și este destinat simulării, sintetizării și încărcării pe o placă FPGA.

Scopul lucrării este de a evidenția diferențele arhitecturale dintre cele două moduri de funcționare și de a analiza impactul mecanismelor de control, inclusiv al unității de hazard, în cazul implementării pipeline. În plus, proiectul urmărește validarea atât în mediul de simulare, cât și pe hardware real.

Autor
Nume: Cupsan Mihai
Titlul lucrării: Implementation of the MIPS Processor in Single-Cycle and Pipelined Variants

Structura repository-ului
Structura proiectului este organizată astfel:

text
/src
    Conține fișierele VHDL ale procesorului:
    - registrul Program Counter
    - memoria de instrucțiuni
    - unitatea de control
    - fișierul de registre
    - decodificatorul ALU
    - unitatea aritmetico-logică
    - memoria de date
    - registrele dintre etapele pipeline
    - unitatea de hazard


/constraints
    Conține fișierul de constrângeri fizice și temporale pentru FPGA
    - nexys4ddr.xdc

README.md
    Documentația proiectului și instrucțiuni de utilizare
Cerințe
Pentru rularea proiectului sunt necesare următoarele:

Xilinx Vivado Design Suite

o placă Nexys 4 DDR bazată pe FPGA Artix-7

un cablu USB compatibil pentru programarea plăcii

Proiectul a fost dezvoltat inițial și testat în Vivado 2015.x, însă poate fi folosit și în versiuni mai recente.

Mod de utilizare
1. Descărcarea repository-ului
Repository-ul poate fi clonat sau descărcat local folosind următoarea adresă:

text
https://gitlab.upt.ro/mihai.cupsan/licenta_cupsan_mihai
2. Crearea unui proiect nou în Vivado
Se deschide Vivado și se creează un proiect de tip RTL Project.
Se adaugă toate fișierele VHDL din directorul /src ca surse de design.
Apoi se adaugă fișierul nexys4ddr.xdc din directorul /constraints ca fișier de constrângeri.
La selectarea dispozitivului, se alege cipul corespunzător plăcii Nexys 4 DDR:

text
xc7a100tcsg324-1
3. Sinteză și simulare
După adăugarea surselor, se rulează Synthesis pentru verificarea corectitudinii codului și pentru transformarea lui într-o structură hardware sintetizabilă.
Pentru validarea funcțională, se adaugă fișierul de testbench din /sim, acesta fiind setat ca modul principal pentru simulare.
Apoi se pornește Behavioral Simulation, unde poate fi urmărită execuția instrucțiunilor stocate în memoria ROM și funcționarea corectă a datapath-ului.

4. Implementare și generarea bitstream-ului
Dacă rezultatele simulării sunt corecte, se continuă cu Implementation.
După finalizarea implementării, se verifică Timing Summary pentru a confirma respectarea constrângerilor de ceas de 100 MHz.
În final, se generează fișierul bitstream, necesar pentru configurarea FPGA-ului.

5. Programarea plăcii FPGA
Placa Nexys 4 DDR se conectează la calculator, iar din Hardware Manager se alege opțiunea Open Target → Auto Connect.
Fișierul .bit generat este apoi încărcat pe placă.
După programare, rezultatele procesării pot fi observate prin perifericele mapate, cum ar fi LED-urile.
