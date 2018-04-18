#!/bin/bash

# Bismillahir Rahmanir Rahim
# Server Side C/C++ Compiler
# Author: Atiab Jobayer

# Parameters:
# Code_Directory Submit_ID Extension

# Get Current Time
START=$(($(date +%s%N)/1000000));

C_OPTIONS="-fno-asm -Dasm=error -lm -O2"
C_WARNING_OPTION="-w"

################### Getting Arguments ###################

# Code Directory Path
CODEPATH=${1}

# Submit ID
SUBMIT_ID=${2}

# Extension
EXT=${3}

################### Initializing Limits ###################

# Time Limit, 3 seconds
TIMELIMIT=3

# Time Limit Integer, 4 seconds (Used in JAVA)
TIMELIMITINT=4

# Memory Limit, 64 MB
MEMLIMIT=65536

# Output Size Limit, 2 MB
OUTLIMIT=2048

################### Initializing Code Executer ###################

LOG="$CODEPATH/log_$SUBMIT_ID"; echo "" >>$LOG

function log
{
	echo -e "$@" >>$LOG 
}


function finish
{
	END=$(($(date +%s%N)/1000000));

	log "\nTotal Execution Time: $((END-START)) ms"
	echo $@

	exit 0
}

log "Starting Compilation..."

# Detecting existence of Perl
PERL_EXISTS=true
hash perl 2>/dev/null || PERL_EXISTS=false

if ! $PERL_EXISTS; then
	log "Perl not found. We continue without Perl..."
fi

JAIL=jail-$SUBMIT_ID
if ! mkdir $JAIL; then
	log "Execution folder is not writable. Exiting process..."
	finish "System Error"
fi

cd $JAIL
cp ../timeout ./timeout
chmod +x timeout

cp ../runcode.sh ./runcode.sh
chmod +x runcode.sh

COMPILE_BEGIN_TIME=$(($(date +%s%N)/1000000));

########################################################################################################
############################################ COMPILING JAVA ############################################
########################################################################################################

if [ "$EXT" = "java" ]; then
	cp ../java.policy java.policy
	cp $CODEPATH/submission_$SUBMIT_ID.java $SUBMIT_ID.java

	log "Compiling Java"

	javac $SUBMIT_ID.java >/dev/null 2>cerr
	EXITCODE=$?

	COMPILE_END_TIME=$(($(date +%s%N)/1000000));
	log "Compiled. Exit Code=$EXITCODE  Execution Time: $((COMPILE_END_TIME-COMPILE_BEGIN_TIME)) ms"
	
	if [ $EXITCODE -ne 0 ]; then
		log "Compilation Error"
		log "$(cat cerr|head -10)"

		echo 'Compilation Error: ' >out
		(cat cerr | head -10 | sed 's/&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g') >out

		cp out $CODEPATH/output_$SUBMIT_ID.txt

		cd ..
		rm -r $JAIL >/dev/null 2>/dev/null

		finish "Compilation Error"
	fi
fi

########################################################################################################
########################################## COMPILING PYTHON 2 ##########################################
########################################################################################################

if [ "$EXT" = "py2" ]; then
	cp $CODEPATH/submission_$SUBMIT_ID.py $SUBMIT_ID.py

	log "Running Python Syntax Validation..."
	
	python2 -O -m py_compile $SUBMIT_ID.py >/dev/null 2>cerr
	EXITCODE=$?

	COMPILE_END_TIME=$(($(date +%s%N)/1000000));

	_log "Compiled. Exit Code=$EXITCODE  Execution Time: $((COMPILE_END_TIME-COMPILE_BEGIN_TIME)) ms"
	
	if [ $EXITCODE -ne 0 ]; then
		log "Compilation Error"
		log "$(cat cerr | head -10)"
		
		echo 'Compilation Error: ' >out
		(cat cerr | head -10 | sed 's/&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g') >> out
		
		cd ..
		rm -r $JAIL >/dev/null 2>/dev/null
		
		finish "Compilation Error"
	fi

	cat ../shield/shield_py2.py | cat - $SUBMIT_ID.py > thetemp && mv thetemp $SUBMIT_ID.py
fi

########################################################################################################
########################################## COMPILING PYTHON 3 ##########################################
########################################################################################################

if [ "$EXT" = "py3" ]; then
	cp $CODEPATH/submission_$SUBMIT_ID.py $SUBMIT_ID.py
	
	log "Running Python Syntax Validation..."

	python3 -O -m py_compile $SUBMIT_ID.py >/dev/null 2>cerr
	EXITCODE=$?

	COMPILE_END_TIME=$(($(date +%s%N)/1000000));
	
	log "Compiled. Exit Code=$EXITCODE  Execution Time: $((COMPILE_END_TIME-COMPILE_BEGIN_TIME)) ms"
	
	if [ $EXITCODE -ne 0 ]; then
		log "Compilation Error"
		log "$(cat cerr | head -10)"
		
		echo 'Compilation Error: ' >out
		(cat cerr | head -10 | sed 's/&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g') >> out

		cp out $CODEPATH/output_$SUBMIT_ID.txt

		cd ..
		rm -r $JAIL >/dev/null 2>/dev/null

		finish "Compilation Error"
	fi

	cat ../shield/shield_py3.py | cat - $SUBMIT_ID.py > thetemp && mv thetemp $SUBMIT_ID.py
fi

########################################################################################################
############################################ COMPILING C/C++ ###########################################
########################################################################################################

if [ "$EXT" = "c" ] || [ "$EXT" = "cpp" ]; then
	COMPILER="gcc"
	
	if [ "$EXT" = "cpp" ]; then
		COMPILER="g++"
	fi

	EXEFILE="s_$(echo $SUBMIT_ID | sed 's/[^a-zA-Z0-9]//g')"

	cp $CODEPATH/submission_$SUBMIT_ID.$EXT code.c

	log "Compiling $EXT"

	cp ../easysandbox/EasySandbox.so EasySandbox.so
	chmod +x EasySandbox.so

	if tr -d ' \t\n\r\f' < code.c | grep -q '#undef'; then
		echo 'code.c: #undef is not allowed' >cerr
		EXITCODE=110
	else
		cp ../shield/shield.$EXT shield.$EXT
		cp ../shield/def$EXT.h def.h

		echo '#define main themainmainfunction' | cat - code.c > thetemp && mv thetemp code.c
		
		$COMPILER shield.$EXT $C_OPTIONS $C_WARNING_OPTION -o $EXEFILE >/dev/null 2>cerr
		
		EXITCODE=$?
	fi

	COMPILE_END_TIME=$(($(date +%s%N)/1000000));

	log "Compiled. Exit Code=$EXITCODE  Execution Time: $((COMPILE_END_TIME-COMPILE_BEGIN_TIME)) ms"

	if [ $EXITCODE -ne 0 ]; then
		log "Compilation Error"
		log "$(cat cerr | head -10)"
		
		echo 'Compilation Error: ' >out

		SHIELD_ACT=false

		while read line; do
			if [ "`echo $line|cut -d" " -f1`" = "#define" ]; then
				if grep -wq $(echo $line|cut -d" " -f3) cerr; then
					echo `echo $line|cut -d"/" -f3` >> out
					SHIELD_ACT=true
					break
				fi
			fi
		
		done <def.h

		if ! $SHIELD_ACT; then
			echo -e "\n" >> cerr
			echo "" > cerr2

			while read line; do
				if [ "`echo $line|cut -d: -f1`" = "code.c" ]; then
					echo ${line#code.c:} >>cerr2
				fi
				if [ "`echo $line|cut -d: -f1`" = "shield.c" ]; then
					echo ${line#shield.c:} >>cerr2
				fi
				if [ "`echo $line|cut -d: -f1`" = "shield.cpp" ]; then
					echo ${line#shield.cpp:} >>cerr2
				fi

			done <cerr
			
			(cat cerr2 | head -10 | sed 's/themainmainfunction/main/g' ) > cerr;
			(cat cerr | sed 's/&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g') >> out
		fi

		cp out $CODEPATH/output_$SUBMIT_ID.txt

		cd ..
		rm -r $JAIL >/dev/null 2>/dev/null
		
		finish "Compilation Error"
	fi
fi

########################################################################################################
############################################### EXECUTION ##############################################
########################################################################################################

touch err

if [ "$EXT" = "java" ]; then
	if $PERL_EXISTS; then
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "./timeout --just-kill -nosandbox -l $OUTLIMIT -t $TIMELIMIT java -mx${MEMLIMIT}k $JAVA_POLICY $SUBMIT_ID"
	else
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "java -mx${MEMLIMIT}k $JAVA_POLICY $SUBMIT_ID"
	fi
		
	EXITCODE=$?
		
	if grep -iq -m 1 "Too small initial heap" out || grep -q -m 1 "java.lang.OutOfMemoryError" err; then
		log "Memory Limit Exceeded"
		echo "Memory Limit Exceeded" >>out
	fi
		
	if grep -q -m 1 "Exception in" err; then # show Exception
		javaexceptionname=`grep -m 1 "Exception in" err | grep -m 1 -oE 'java\.[a-zA-Z\.]*' | head -1 | head -c 80`
		javaexceptionplace=`grep -m 1 "$MAINFILENAME.java" err | head -1 | head -c 80`
		
		log "Exception: $javaexceptionname\nMaybe at:$javaexceptionplace"

		if $DISPLAY_JAVA_EXCEPTION_ON && grep -q -m 1 "^$javaexceptionname\$" ../java_exceptions_list; then
			echo "Runtime Error : ($javaexceptionname)</span>" >>out
		fi

	fi
elif [ "$EXT" = "c" ] || [ "$EXT" = "cpp" ]; then
	if $PERL_EXISTS; then
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "./timeout --just-kill --sandbox -l $OUTLIMIT -t $TIMELIMIT -m $MEMLIMIT ./$EXEFILE"
	else
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "LD_PRELOAD=./EasySandbox.so ./$EXEFILE"
	fi
			
	EXITCODE=$?

	tail -n +2 out >thetemp && mv thetemp out
elif [ "$EXT" = "py2" ]; then
	if $PERL_EXISTS; then
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "./timeout --just-kill -nosandbox -l $OUTLIMIT -t $TIMELIMIT -m $MEMLIMIT python2 -O $SUBMIT_ID.py"
	else
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "python2 -O $SUBMIT_ID.py"
	fi
	
	EXITCODE=$?

elif [ "$EXT" = "py3" ]; then
	if $PERL_EXISTS; then
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "./timeout --just-kill -nosandbox -l $OUTLIMIT -t $TIMELIMIT -m $MEMLIMIT python3 -O $SUBMIT_ID.py"
	else
		./runcode.sh $EXT $MEMLIMIT $TIMELIMIT $TIMELIMITINT $CODEPATH/input_$SUBMIT_ID.txt "python3 -O $SUBMIT_ID.py"
	fi
	
	EXITCODE=$?

else
	log "File Format Not Supported"
		
	cd ..
	rm -r $JAIL >/dev/null 2>/dev/null
	finish "File Format Not Supported"
fi

if ! grep -q "FINISHED" err; then
	if grep -q "SHJ_TIME" err; then
		t=`grep "SHJ_TIME" err|cut -d" " -f3`
		log "Time Limit Exceeded ($t s)"
		echo "Time Limit Exceeded" >>out

	elif grep -q "SHJ_MEM" err; then
		log "Memory Limit Exceeded"
		echo "Memory Limit Exceeded" >>out
		
	elif grep -q "SHJ_HANGUP" err; then
		log "Hanged Up"
		echo "Runtime Error" >>out

	elif grep -q "SHJ_SIGNAL" err; then
		log "Killed"
		echo "Runtime Error" >>out

	elif grep -q "SHJ_OUTSIZE" err; then
		log "Output Size Limit Exceeded"
		echo "Output Size Limit Exceeded" >>out
	fi
else
	t=`grep "FINISHED" err|cut -d" " -f3`
	log "Time: $t s"
fi

if [ $EXITCODE -eq 137 ]; then
		log "Killed (Exit Code = 137)"
		echo "Time Limit Exceeded" >>out
fi

if [ $EXITCODE -ne 0 ]; then
	log "Runtime Error"
	echo "Runtime Error" >>out
fi

cp out $CODEPATH/output_$SUBMIT_ID.txt

cd ..
rm -r $JAIL >/dev/null 2>/dev/null

log "Compilation Successful"

finish "Success"