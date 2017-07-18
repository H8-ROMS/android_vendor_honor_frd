#!/system/bin/sh
#mount -t debugfs none /sys/kernel/debug
sleep 12

echo "starting the loop"

logbase=/data/hwzd_logs
if [ ! -e $logbase/kmemleak_logs ]; then
    mkdir $logbase/kmemleak_logs
fi
logpath=$logbase/kmemleak_logs

kmemleakflag=0

if [ ! -e /sys/kernel/debug/kmemleak ]; then
	echo "/sys/kernel/debug/kmemleak doesn't exist. Not a kmemleak enabled build; exiting $0"
	let kmemleakflag=1
fi

counta=1
countb=1
countc=1
iondump_flag=1
mem_proc_slab_flag=1

while true
do
	if [ $kmemleakflag -eq 0 ]; then
		echo "Iteration $counta" >> $logpath/kmemleak.log
		echo ------------------ >> $logpath/kmemleak.log
		cat /sys/kernel/debug/kmemleak >> $logpath/kmemleak.log
		cat /proc/buddyinfo >> $logpath/kmemleak.log
		echo clear > /sys/kernel/debug/kmemleak
		echo scan > /sys/kernel/debug/kmemleak
		let counta=counta+1
	fi

	sleep 5
	let iondump_flag=iondump_flag+1
	let mem_proc_slab_flag=mem_proc_slab_flag+1

	if [ $mem_proc_slab_flag -eq 13 ]; then
		echo "Iteration $countb" >> $logpath/meminfo.log
		date >> $logpath/meminfo.log
		echo ------------------ >> $logpath/meminfo.log
		echo "Iteration $countb" >> $logpath/procrank.log
		date >> $logpath/procrank.log
		echo ------------------ >> $logpath/procrank.log
		echo "Iteration $countb" >> $logpath/slabinfo.log
		date >> $logpath/slabinfo.log
		echo ------------------ >> $logpath/slabinfo.log
		echo "Iteration $countb" >> $logpath/pagetypeinfo.log
		date >> $logpath/pagetypeinfo.log
		echo ------------------ >> $logpath/pagetypeinfo.log
		echo "Iteration $countb" >> $logpath/dumpsys-meminfo.log
		date >> $logpath/dumpsys-meminfo.log
		echo ------------------ >> $logpath/dumpsys-meminfo.log
		cat /proc/meminfo >> $logpath/meminfo.log
		procrank >> $logpath/procrank.log
		cat /proc/slabinfo >> $logpath/slabinfo.log
		cat /proc/pagetypeinfo >> $logpath/pagetypeinfo.log
		dumpsys meminfo >> $logpath/dumpsys-meminfo.log
		let countb=countb+1
		let mem_proc_slab_flag=1
		echo >> $logpath/meminfo.log
		echo >> $logpath/meminfo.log
		echo >> $logpath/procrank.log
		echo >> $logpath/procrank.log
		echo >> $logpath/slabinfo.log
		echo >> $logpath/slabinfo.log
		echo >> $logpath/pagetypeinfo.log
		echo >> $logpath/pagetypeinfo.log
		echo >> $logpath/dumpsys-meminfo.log
		echo >> $logpath/dumpsys-meminfo.log
	fi

	if [ $iondump_flag -eq 61 ]; then
		echo "Iteration $countc at `date`" >> $logpath/iondump.log
		echo ------------------ >> $logpath/iondump.log
		for i in `ls /d/ion/heaps`
		do
			echo $i Info >> $logpath/iondump.log
			echo ------------------ >> $logpath/iondump.log
			echo >> $logpath/iondump.log
			cat /d/ion/heaps/$i >> $logpath/iondump.log
		done
		let countc=countc+1
		let iondump_flag=1
		echo >> $logpath/iondump.log
	fi
done
