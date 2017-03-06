#! /bin/bash

echo flex -Ca a.fl 
flex -Ca a.fl 
echo cc lex.yy.c -lfl
cc lex.yy.c -lfl
