#!/bin/sh

openssl genrsa –out monthlys.key –des3 2048
openssl req –new –key monthlys.key –out monthlys-wildcard.csr 
