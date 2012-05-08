#===================================================================================
#
#
# ARCHIVO: StartD.sh
#
# Uso: Inicia la ejecución del demonio.
# Pre-condiciones: 
# -ambiente inicializado 
# -el demonio todavía no ha sido ejecutado.
#===================================================================================

#!/bin/sh

if [ -z "$BINDIR" ]
then
	echo "Error: el ambiente no fue inicializado."
	exit 1
else
	pid=`pgrep 'DetectarT.sh'`
	if [ $? -eq 0 ]
	then
		echo "Error: DetectarT ya se está ejecutando bajo pid=${pid}."
		exit 1
	else
		${BINDIR}/DetectarT.sh&
		pid=`pgrep 'DetectarT.sh'`
		echo "Se inicia la ejecución de DetectarT bajo el pid=${pid}."
		exit 0
	fi
fi

