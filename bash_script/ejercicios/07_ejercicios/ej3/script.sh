#!/bin/bash

tmpfile=$(mktemp)

while read LINE; do

        var1=$(echo $LINE | grep beta)

        if [ $? -eq 0 ]; then
                var1=$(echo $LINE | grep beta | sed -e "s/192.168.4/10.0.133/g")
                corte1=$(echo $var1 | cut -d ' ' -f1 | cut -d '.' -f4)
                corte2=$(echo $var1 | cut -d ' ' -f2)
                mod2=$(echo $corte2 | sed -e "s/beta/alfa/g")
                corte3=$(echo $var1 | cut -d ' ' -f3)
                mod3=$(echo $corte3 | sed -e "s/beta/a2eq/g")
                numeroNN=$(($corte1+40))
                echo $LINE
                echo $var1 | sed -e "s/$corte2/$mod2/g" -e "s/$corte3/$mod3/g" -e "s/$corte1/$numeroNN /g" | tee -a $tmpfile
        else
                echo $LINE >> $tmpfile
        fi

done < /etc/hosts

cp -pv $tmpfile /etc/hosts
rm -f $tmpfile

