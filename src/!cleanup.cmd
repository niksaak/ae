@echo off
rem ------------------------------------------------------------------------
rem
rem Simple script for deleting unnecessary Delphi 7 compiled data. :)
rem
rem Author: dsp2003. For Delphi projects. Use at your own risk. ;)
rem
rem ------------------------------------------------------------------------
title Deleting compilation garbage...
cd .
del *.dcu
del *.ddp
del *.~*

del format\*.dcu
del format\*.ddp
del format\*.~*

del format\archives\*.dcu
del format\archives\*.ddp
del format\archives\*.~*

del format\graphics\*.dcu
del format\graphics\*.ddp
del format\graphics\*.~*

del precompiled\*.* /Q

title Deleting compilation garbare... - DONE