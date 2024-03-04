# Image-Processing-HDL-3rd-year
## Cerinte
* Implementați în Verilog un circuit secvențial sincron care prelucrează imagini RGB (cu trei canale de culoare, fiecare pe 8 biți). Imaginile au dimensiunea de 64×64 de elemente, în care fiecare element are 24 de biți (8 biți 'R', 8 biți 'G' și 8 biți 'B').
* Efectuați transformarea imaginii prin oglindire. Oglindirea va fi realizată pe verticală, relativ la rândurile imaginii.
* Realizați echivalentul imaginii în grayscale. Imaginea rezultantă va fi stocată pe 8 biți în canalul 'G'. Valoarea din canalul 'G' va fi calculată drept media dintre maximul si minimul valorilor din cele trei canale. După această operație, canalele 'R' și 'B' vor fi setate pe valoarea '0'. Filtrul grayscale va fi realizat pe imaginea oglindită.
