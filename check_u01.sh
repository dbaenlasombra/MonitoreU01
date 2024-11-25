#!/bin/bash
# DSM NTTDATA-DBA

. /home/oracle/.bashrc

NAME=`df -h | grep u01 | awk '{print $6}'`
USE=`df -h | grep u01 | awk '{print $5}' | sed -r 's/%//g'`
ADRCI_LOG="adrci_"`date +%Y%m%d%H%M%S`".log"
TODAY=$(date '+%Y-%m-%d %H:%M:%S')

# 5 sera el numero de dias que queremos mantener a nivel de trace
PURGE=$(expr 5 \* 24 \* 60)

if [[ ${USE} -gt 80 ]]
then

lanza_sqlplus() {
    sqlplus -s ${VUSER}/${VPASS}@${LOCAL_SID} <<EOF
    set lines 200 pages 9000
    set termout off
    set heading off
    ${SQL}
    EXIT;
EOF
}
      SQL=$(cat <<EOF
        Select Value||chr(47) From V\$diag_Info Where Name='ADR Base'
         ;
EOF
)
    set __ $(lanza_sqlplus)
    ADRCI_BASE=${2}

      SQL=$(cat <<EOF
        Select Replace( Value, (Select Value || Chr(47) From V\$diag_Info Where Name='ADR Base'),'')  Value
          From V\$diag_Info Where Name='ADR Home'
         ;
EOF
)
   set __ $(lanza_sqlplus)
   ADRCI_HOME=${2}

   echo "Base " ${ADRCI_BASE} " home " ${ADRCI_HOME}

   adrci exec="set echo ON; spool ${P_RAIZ}/log/${ADRCI_LOG} append; set base ${ADRCI_BASE}; set homepath ${ADRCI_HOME}; purge -age ${PURGE}" >>  ${P_RAIZ}/log/${ADRCI_LOG}

   USE_ACTUAL=`df -h | grep u01 | awk '{print $5}' | sed -r 's/%//g'`

   printf "Mantenimient ${NAME}\nSize Ant=${USE}\nAct=${USE_ACTUAL}"  | mailx -s "[XXXX][XXXX] Mantenimiento ${NAME} with more ${USE} - ${TODAY}." ${EMAIL}


  fi
