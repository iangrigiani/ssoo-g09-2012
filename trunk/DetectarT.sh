#===================================================================================
#
#
# ARCHIVO: DetectarT.sh
#
# USO: Se invoca a traves del script StartD.sh y se finaliza mediante el script StopD.sh
#
# DESCRIPCION: Valida el nombre de los archivos contenidos en la carpeta
# Si tanto el nombre como las fechas son correctas, mueve a la carpeta correspondiente para su posterior proceso
# En caso contrario, mueve el archivo a la carpeta de rechazados y graba el error en el log
# Graba en un archivo de log el resultado de la operacion.
#
#===================================================================================
#!/bin/bash


function validarNombre
{
fila=`grep ^$1,\".*\",$2, < ${MAEDIR}/sucu.mae`
if [ -n "$fila" ]
then
	return 0
else
	return 1
fi
}


function validarFechas
{

#Formato de las fechas: dd/mm/aaaa
desde=`echo "$1" | sed 's/^.*,\([0-9].*\),[^,]*$/\1/'`
hasta=`echo "$1" | sed 's/.*,\([^,]*\)/\1/'`

fecha_actual=`date +"%Y%m%d"`


if [ $desde ]
then
	desde=`echo $desde | sed 's&\/&&g'`
	desde=`echo $desde | sed 's/\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{4\}\)/\3\2\1/'`
	
	if [ $fecha_actual -ge $desde ]
	then
		if [ $hasta ]
		then
			hasta=`echo $hasta | sed 's&\/&&g'`
			hasta=`echo $hasta | sed 's/\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{4\}\)/\3\2\1/'`
			if [ $fecha_actual -le $hasta ]
			then
				return 0
			else
				return 1
			fi
		else
			return 0
		fi
	else
		return 1
	fi
else
	return 1
fi


#Cuerpo Principal / Ciclo infinito

echo "********* INICIO **************"
while [ 1 ]
do 

archivos=`ls $ARRIDIR`

if [ -n "$archivos" ]
then
	for nombre in $archivos	
	do
		region_id=`echo $nombre | sed 's/\(.*\)-.*/\1/'`
		branch_id=`echo $nombre | sed 's/.*-\(.*\)/\1/'`
	
		validarNombre $region_id $branch_id
		
		if [ $? -eq 0 ]
		then
			#El nombre del archivo es valido
			#Obtengo y valido las fechas
			validarFechas "$fila"
			if [ $? -eq 0 ]
			then
				# MOVER a preparados
				$MoverT.sh & "DetectarT.sh" "inst_recibidas" "DetectarT" "Archivo valido. Se mueve a la carpeta inst_recibidas para su procesamiento"
				echo "Fechas validas"
			else
				# MOVER a rechazados
				$MoverT.sh & "DetectarT.sh" "${RECHDIR}" "DetectarT" "Archivo invalido - La fecha actual esta fuera del rango de fechas de las actividades. Se mueve a la carpeta ${RECHDIR}"
				echo "Fechas no validas"
			fi
		else
			echo "Nombre no valido"
			# MOVER a rechazados
			$MoverT.sh & "DetectarT.sh" "${RECHDIR}" "DetectarT" "Archivo invalido - El nombre del archivo no coincide con ningun par region_id-branch_id. Se mueve a la carpeta ${RECHDIR}"
		fi
	done
fi

# Busco si hay archivos pendientes de procesamiento

pendientes=`ls ${GRUPO}/inst_recibidas`
if [ -n "$pendientes" ]
then
pid=`pgrep GrabarParqueT.sh`
	if [ $? -eq 0 ]
	then
		echo "Error: GrabarParqueT ya se está ejecutando bajo pid=${pid}."
	else
		${BINDIR}/GrabarParqueT.sh &
		pid=`pgrep 'GrabarParqueT.sh'`
		echo "Se inicia la ejecución de GrabarParqueT bajo el pid=${pid}."
	fi
fi
echo "********** FIN *************"
sleep 2s
done

