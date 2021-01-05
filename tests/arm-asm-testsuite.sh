#!/bin/sh

set -e

# Note: "{r3}" is definitely different--but would complicate the assembler.

state="`mktemp -d`"
cat arm-tok.h |grep DEF_ASM_CONDED |grep -v '#define' |grep -v '/[*]' |sed -e 's;DEF_ASM_CONDED.\(.*\).$;\1;'| grep -v 'not useful' | while read s
do
	ok=0
	for args in "r3, r4, r5, r6" \
	            "r3, r4, r5" \
	            "r3, r4, r5, asl #7" \
	            "r3, r4, r5, lsl #7" \
	            "r3, r4, r5, asr #7" \
	            "r3, r4, r5, lsr #7" \
	            "r3, r4, r5, ror #7" \
	            "r3, r4, r5, rrx" \
	            "r3, r4, r5, asl r6" \
	            "r3, r4, r5, lsl r6" \
	            "r3, r4, r5, asr r6" \
	            "r3, r4, r5, lsr r6" \
	            "r3, r4, r5, ror r6" \
	            "r3, r4, #5, asl #7" \
	            "r3, r4, #5, lsl #7" \
	            "r3, r4, #5, asr #7" \
	            "r3, r4, #5, lsr #7" \
	            "r3, r4, #5, ror #7" \
	            "r3, r4, #5, rrx" \
	            "r3, #5, r4" \
	            "r3, #4, #8" \
	            "r3, r4, asl #5" \
	            "r3, r4, lsl #5" \
	            "r3, r4, asr #5" \
	            "r3, r4, lsr #5" \
	            "r3, r4, ror #5" \
	            "r3, r4, ror #8" \
	            "r3, r4, asl r5" \
	            "r3, r4, lsl r5" \
	            "r3, r4, asr r5" \
	            "r3, r4, lsr r5" \
	            "r3, r4, ror r5" \
	            "r3, r4, ror #8" \
	            "r3, r4, ror #16" \
	            "r3, r4, ror #24" \
	            "r3, r4, rrx" \
	            "r3, #4, asl #5" \
	            "r3, #4, lsl #5" \
	            "r3, #4, asr #5" \
	            "r3, #4, lsr #5" \
	            "r3, #4, ror #5" \
	            "r3, r4, rrx" \
	            "r3, r4" \
	            "r3" \
	            "{r3,r4,r5}" \
	            "{r3,r5,r4}" \
	            "r2!, {r3,r4,r5}" \
	            "r2!, {r3,r5,r4}" \
	            "r2, [r3, r4]" \
	            "r2, [r3, r4]!" \
	            "r2, [r3, -r4]" \
	            "r2, [r3, -r4]!" \
	            "r2, [r3], r4" \
	            "r2, [r3]" \
	            "r2, r3, [r4]" \
	            "r2, [r3, #4]" \
	            "r2, [r3, #-4]" \
	            "r2, r3, #4" \
	            "r2, r3, #-4" \
	            "r2, #4" \
	            "r2, #-4" \
	            "r2, #0xEFFF" \
	            "r3, #0x0000" \
	            "r4, #0x0201" \
	            "r4, #0xFFFFFF00" \
	            "r2, #-4" \
	            "#4" \
	            "#-4" \
	            ""
	do
		#echo ".syntax unified" > a.s
		err="`mktemp --suffix=-stderr.log`"
		as_object="${state}/as-$s $args.o"
		tcc_object="${state}/tcc-$s $args.o"
		expected="${state}/expected-$s $args"
		got="${state}/got-$s $args"
		if echo "$s $args" | "${CROSS_COMPILE}as" -mlittle-endian -o "${as_object}" - 2>"${err}"
		then
			cat "${err}"
			rm -f "${err}"
			total_count=`expr $total_count + 1`
			objdump -S "${as_object}" |grep "^[ ]*0:" >"${expected}"

			#echo '__asm__("'"$s ${args}"'");' > "${csource}"
			if echo '__asm__("'"$s ${args}"'");'| ./tcc -o "${tcc_object}" -c -
			then
				objdump -S "${tcc_object}" |grep "^[ ]*0:" >"${got}"
				if diff -u "${got}" "${expected}"
				then
					touch "${state}/ok-$s $args"
				else
					echo "warning: '$s $args' did not work in tcc (see above)">&2
				fi
			else
				rm -f "${tcc_object}"
				echo "warning: '$s $args' did not work in tcc">&2
			fi
			ok=1
		else # GNU as can't do it either--so we don't care
			rm -f "${as_object}"
		fi
		rm -f "${err}"
	done
	if [ "${ok}" -eq "0" ]
	then
		echo "warning: $s could not be used.">&2
		continue
	fi
done

successful_count="$(ls -1 "${state}/ok-"* |wc -l)"
total_count="$(ls -1 "${state}/as-"*.o |wc -l)"
rm -rf "${state}"
echo "${successful_count} of ${total_count} tests succeeded.">&2
if [ "${successful_count}" -eq "${total_count}" ]
then
	exit 0
else
	exit 1
fi
