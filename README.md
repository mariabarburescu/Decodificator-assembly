# Decodificator-assembly

Acest program decodează o serie de șiruri codificate prin diferite metode criptografice.
1.	XOR între două șiruri de octeți: se realizează operația xor între fiecare octet din mesaj cu octetul corespondent din cadrul cheii.
2.	Rolling XOR: se efectuează operația xor între rezultatul respectiv și blocul ce urmează a fi criptat, după care are loc criptarea 
propriu-zisă folosind o cheie de criptare.
3.	XOR între două șiruri reprezentate prin caractere hexazecimale: șirul de caractere și cheia se convertesc în hexazecimal după care se 
aplică XOR între șiruri asemea primei metode.
4.	Decodificarea unui șir în reprezentare base32: base32 este o metodă de codificare de tip binary to text. Funcționează în baza 
următorului algoritm: pentru fiecare 5 octeți, se vor genera 8 valori cuprinse între 0 și 31, conform unei scheme standard. Valorile 
generate vor fi folosite ca indecși în alfabetul base32 pentru a determina cele 8 caractere care vor fi folosite pentru codificarea 
datelor.
5.	Bruteforce pe XOR cu cheie de un octet: trebuie identificată cheia folosită pentru obținerea mesajului codificat.
