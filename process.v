`timescale 1ns / 1ps

module process(
	input clk,				// clock 
	input [23:0] in_pix,	// valoarea pixelului de pe pozitia [in_row, in_col] din imaginea de intrare (R 23:16; G 15:8; B 7:0)
	output reg [5:0] row, col, 	// selecteaza un rand si o coloana din imagine
	output reg out_we, 			// activeaza scrierea pentru imaginea de iesire (write enable)
	output reg [23:0] out_pix,	// valoarea pixelului care va fi scrisa in imaginea de iesire pe pozitia [out_row, out_col] (R 23:16; G 15:8; B 7:0)
	output reg mirror_done,		// semnaleaza terminarea actiunii de oglindire (activ pe 1)
	output reg gray_done,		// semnaleaza terminarea actiunii de transformare in grayscale (activ pe 1)
	output reg filter_done);	// semnaleaza terminarea actiunii de aplicare a filtrului de sharpness (activ pe 1)
	
	parameter START = 4'b0000;
	parameter IDLE = 4'b0001;
	parameter MIRROR = 4'b0010;
	parameter MIRROR1 = 4'b0011;
	parameter MIRROR2 = 4'b0100;
	parameter MIRROR3 = 4'b0101;
	parameter GRAYSCALE = 4'b0110;
	parameter GRAYSCALE1 = 4'b0111;
	
	reg [3:0] state=0, next_state;
	reg [7:0] min_gray, max_gray, gray_val;
	
// TODO add your finite state machines here
	
	
	always@(posedge clk) begin	
	
		case(state)
		
			START: begin
			//case pentru initializarea datelor
			
				mirror_done=0;
				gray_done=0;
				filter_done=0;
				out_we=0;
				next_state = IDLE;
				state=next_state;
				
			end
			
			IDLE: begin	
			//case care verifica daca mirror, grayscale sunt realizate
			
				row=0;	//dupa finalizarea fiecarui proces revenim in IDLE, de aceea setam randul si coloana sa fie 0, pentru urmatorul proces
				col=0;
				
				if(!mirror_done)begin
					next_state=MIRROR;
					state=next_state;
					
				end else if(!gray_done)begin
					next_state=GRAYSCALE;
					state=next_state;
				end
				
				//urma si o verificare daca s-a realizat transformarea imaginii cu filtru de sharpness
				//nu am mai implementat acest subpunct
				
			end
				
			MIRROR: begin 	
			//in aces case are loc oglindirea unei perechi de 2 pixeli
			//exp:[0,0] cu [0,63]
				
				if(row<32) begin	
				//out_pix va avea valoarea primului pixel din pereche (din jumatatea de sus a matrici) 
										
					row=63-row;
					out_we = 1;
					
					out_pix = in_pix;
					
					next_state = MIRROR;
					state=next_state;
					
				end else if(row>32) begin	
				//aici se realizeaza prima parte a oglindirii, al doilea pixel a perechii va fii egal cu primul
				
					row=63-row;
					out_we = 1;
				
					out_pix = in_pix;
				
					next_state = MIRROR1;
					state=next_state;
				
				end else if(row==32&&col<63)begin
				//cazul special in care am ajuns la ultima pereche care trebuie parcursa de pe o coloana	
				//are loc prima parte a oglindirii, identica cu cea unde row>32, doar ca trecem la MIRROR2 
					
					row=63-row;
					out_we=1;
					
					out_pix = in_pix;
					
					next_state = MIRROR2;
					state=next_state;
				
				end else if(row==32&&col==63)begin
				//cazul in care am ajuns la ultima pereche de pixeli din intreaga imagine
				//se finalizeaza oglindirea ultimei perechi de pixeli din toata imaginea, dupa care trecem la MIRROR3
				
					row=63-row;
					
					out_pix=in_pix;
					
					next_state = MIRROR3;
					state=next_state;
	
				end
			
			end
				
			MIRROR1: begin 
			//primul pixel al perechii ia valoarea celui de al doilea din pereche
			//s-a terminat oglindirea pe o pereche de 2 pixeli
			//trecem pe randul urmator, pentru a modifica urmatoare pereche de pixeli 
				
				row=row+1;
				out_we=0;
							
				out_pix=in_pix;
							
				next_state=MIRROR;
				state=next_state;
				
			end
				
			MIRROR2: begin 
			//se finalizeaza oglindirea pe ultima pereche de pixeli care trebuia parcursa de pe coloana curenta
			//in acest case trecem pe coloana urmatoare
			//row=0 pentru a lua coloana noua de la inceput 
				
				row=0;
				col=col+1;
				out_we=0;
				
				out_pix=in_pix;
						
				next_state=MIRROR;
				state=next_state;
				
			end 
				
			MIRROR3: begin
			//se finalizeaza oglindirea ultimei perechi de pixeli din toata imaginea 
			//mirror_done=1 deoarece am terminat procesul de oglindire
			//revenim la IDLE pentru a continua cu urmatorul proces
							
				mirror_done = 1;

				next_state = IDLE;
				state = next_state;
				
			end
				
			GRAYSCALE: begin
			//in acest case se realizeaza transformarea grayscale pe un pixel
				
				out_we=1;
							
				//se calculeaza minimul dintre cele 3 canale(RGB) ale pixelului
				if(in_pix[23:16]<in_pix[15:8])begin
					min_gray=in_pix[23:16];
				end else begin 
					min_gray=in_pix[15:8];
				end
								
				if(in_pix[7:0]<min_gray)begin
					min_gray=in_pix[7:0];
				end
							
				//se calculeaza maximul dintre cele 3 canale(RGB) ale pixelului
				if(in_pix[23:16]>in_pix[15:8])begin
					max_gray=in_pix[23:16];
				end else begin 
					max_gray=in_pix[15:8];
				end
								
				if(in_pix[7:0]>max_gray)begin
					max_gray=in_pix[7:0];
				end
						
				//gray_value reprezinta media dintre minimul si maximul celor 3 canale(RGB) ale pixelului
				gray_val=(min_gray+max_gray)/2;
					
				//canalul G ia valoarea mediei, conform cerintei, iar canalele R si B valoarea 0
				out_pix[23:16]=0;
				out_pix[15:8]=gray_val;
				out_pix[7:0]=0;
					
				//trecem la GRAYSCALE1 unde vom avea verificari	
				next_state=GRAYSCALE1;
				state=next_state;	
								
			end
				
			GRAYSCALE1: begin
				
				out_we=1;
				
				//verificam daca am ajuns la ultimul pixel
				//daca da procesul de grayscale e terminat 
				if(row==63&&col==63)begin
					gray_done=1;
					next_state=IDLE;
					state=next_state;
				
				//daca am ajuns la capatul unei coloane interioare, trecem pe urmatoarea
				end else if(row==63&&col<63)begin
					col=col+1;
					row=0;
					next_state=GRAYSCALE;
					state=next_state;
				
				//daca nu am ajuns la capatul coloanei crestem randul
				end else if(row<63&&col<=63)begin
					row=row+1;
					next_state=GRAYSCALE;
					state=next_state;
				end 
				
			end
						
		endcase
		
	end
	
endmodule					
	
