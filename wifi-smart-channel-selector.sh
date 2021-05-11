#########################################################################
# Best WiFi Channel selector for OpenWRT				#
# Author Kuamr Mrinal (kumar@cnctdwifi.com)				#
# https://cnctdwifi.com							#
#########################################################################


/usr/sbin/iw wlan0 scan | grep -E "primary channel|signal" > /tmp/wifiScan

filename="/tmp/wifiScan"
zero=0

for CHANNEL in 1 2 3 4 5 6 7 8 9 10 11
do
        eval CHANNEL_$CHANNEL="\$zero"
done
echo "CHANNEL_5 : $CHANNEL_2"

while read -r line; do
        FIRST=`echo "$line" | awk '{ print $1 }'`
        if [[ "$FIRST" == "signal:" ]]; then
                SIGNAL=`echo $line | awk '{ print ($2 < -80) ? "NO" : $2 }'`
        fi
        if [[ "$FIRST" == "*" -a "$SIGNAL" != "NO" ]]; then
                CHANNEL=`echo "$line" | awk '{ print $4 }'`
                eval "CURRENT_VALUE=CHANNEL_$CHANNEL"
                eval "CURRENT_VALUE=$CURRENT_VALUE"
                SUM=$(( $CURRENT_VALUE + 1 ))
                eval "CHANNEL_${CHANNEL}=$SUM"
        fi
done < "$filename"

MIN_CHANNEL=1
MIN_ESSID_COUNT=100000

for ITERATION in $(seq 1 1 $ITERATIONS)
do
  for CHANNEL in 1 2 3 4 5 6 7 8 9 10 11
  do
        eval CURRENT_COUNT="\$CHANNEL_$CHANNEL"
        echo "CURRENT_COUNT :: $CURRENT_COUNT"
        if [ $MIN_ESSID_COUNT -gt $CURRENT_COUNT ];
        then
                eval MIN_ESSID_COUNT="\$CURRENT_COUNT"
                eval MIN_CHANNEL="\$CHANNEL"
        fi
  done
done

echo "Min crowded channel : $MIN_CHANNEL"
echo "Min essid count : $MIN_ESSID_COUNT"

if [ $channelSet -ne $MIN_CHANNEL ];
then
        echo "set cheannle to $MIN_CHANNEL"
        uci set wireless.radio0.channel="$MIN_CHANNEL"
        uci commit wireless
        wifi
fi

