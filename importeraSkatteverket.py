#!/usr/bin/python
# -*- coding: utf8 -*-

# Importera en råfil från Skatteverket, som under
# Samtliga tabeller (29-37) för månadslön och tvåveckorslön samt skattetabellerna för sjömän:
# Textfil, månadslön
# http://www.skatteverket.se/download/18.71004e4c133e23bf6db80007320/Allmänna+tabeller+-+månad.zip

import sys

f = open(sys.argv[1],'r')
s = f.readlines()
f.close()

t = []
for num in range(29,38):
	t.append([])

for line in s:
	sats = int(line[3:5])
	v1 = line[5:12].strip()
	v2 = line[12:19].strip()
	v3 = line[19:24].strip()
	t[sats-29].append("%s;%s;%s" % (v1,v2,v3))
	
for num in range(29,38):
	i = num - 29
	f = open('%d.csv' % (num,),'w')
	for line in t[i]:
		f.write(line + '\n');
	f.close()

		