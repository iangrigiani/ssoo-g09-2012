#===================================================================================
#
#
# ARCHIVO: StopD.sh
#
# Uso: Detiene la ejecución del demonio.
# Pre-condiciones: 
# -el demonio todavía ya ha sido ejecutado.
#===================================================================================
#!/bin/sh

pid=`pgrep 'DetectarT.sh'`
if [ $? -eq 0 ] 
then
	kill $pid
	echo "Se detiene la ejecución de DetectarT.sh bajo el pid=${pid}"
	exit 0
else
	echo "Error: DetectarT.sh no se estaba ejecutando"
	exit 1

fi
	
