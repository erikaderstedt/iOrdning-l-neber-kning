#!/usr/bin/python
# -*- coding: utf8 -*-

# Delar upp filer som den här:
# http://www.skatteverket.se/download/18.8dcbbe4142d38302d7198a/1391608918405/Allmanna_tabeller_manad.txt
# i olika filer 29.csv osv.
import sys

if len(sys.argv) < 2:
	print "Ingen indatafil"

f = open(sys.argv[1], "r")
contents = f.read().decode('utf-16')
f.close()

lines = contents.split('\n')
output_files = {}
current_tax_level = 0
current_tax_file = None
for line in lines:
	(tax_level, from_income, to_income, tax_value) = [int('0'+v.strip()) for v in (line[3:5], line[5:12],line[12:19],line[19:24])]

	if tax_level != current_tax_level:
		if current_tax_file != None:
			current_tax_file.close()
		current_tax_level = tax_level
		current_tax_file = open('%d.csv' % (current_tax_level,), 'w')

	current_tax_file.write('%d;%d;%d\n' % (from_income, to_income, tax_value))

current_tax_file.close()
	
	