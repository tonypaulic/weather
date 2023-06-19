#!/bin/bash
# genmon script to query and display weather data from wttr.in (https://github.com/chubin/wttr.in)
# requires: curl & weather icons (https://github.com/kevin-hanselman/xfce4-weather-mono-icons)
# Note: depending on the font your are using, you may need to adjust the number of "\t" (tabs) 
#       in the tooltip string to get the readings to line up properly.

########################################################################################################################
### CONFIGURATION - CHANGE THESE VALUES TO SUIT
SITE="Whitby"               # Location text to display in tooltip
LATITUDE="43.897"                      
LONGITUDE="-78.951"
    #CLICK_COMMAND="xfce4-terminal -H --geometry=126x41 -T Weather -x curl -s wttr.in/$LATITUDE,$LONGITUDE"
CLICK_COMMAND="xdotool key F12"

########################################################################################################################
### SCRIPT GLOBALS
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ICONS_DIR="$SCRIPT_DIR/weather-icons/22/"

########################################################################################################################
### CODE 
# parse date format
function toDate
{
	echo -n "$(date -d $1 '+%-l'):"	# hour
	echo -n "$(date -d $1 '+%M') "	# minute
	echo -n "$(date -d $1 '+%P')"	# am/pm
}

# get the weather data
OUT=$(curl -s wttr.in/$LATITUDE,$LONGITUDE?m\&format="%x\n%c\n%h\n%t\n%f\n%w\n%l\n%m\n%M\n%p\n%P\n%D\n%S\n%z\n%s\n%d\n%u\n%C\n"&nonce=$RANDOM)

# parse the weather data
WEATHERSYMBOL=$(echo $OUT | awk '{print $1}')
WEATHERICON=$(echo $OUT | awk '{print $2}')
HUMIDITY=$(echo $OUT | awk '{print $3}')
TEMPERATURE=$(echo $OUT | awk '{print $4}' | sed -e 's/+//g' | sed -e 's/^-0/0/g' )
FEELSLIKE=$(echo $OUT | awk '{print $5}' | sed -e 's/+//g' | sed -e 's/^-0/0/g' )
WIND=$(echo $OUT | awk '{print $6}')
LOCATION=$(echo $OUT | awk '{print $7}')
MOONPHASE=$(echo $OUT | awk '{print $8}')
MOONDAY=$(echo $OUT | awk '{print $9}')
PRECIPITATION=$(echo $OUT | awk '{print $10}')
PRESSURE=$(echo $OUT | awk '{print $11}')
DAWN=$(toDate "$(echo $OUT | awk '{print $12}')")
SUNRISE=$(toDate "$(echo $OUT | awk '{print $13}')")
ZENITH=$(toDate "$(echo $OUT | awk '{print $14}')")
SUNSET=$(toDate "$(echo $OUT | awk '{print $15}')")
DUSK=$(toDate "$(echo $OUT | awk '{print $16}')")
UVINDEX=$(echo $OUT | awk '{print $17}')
WEATHERCONDITION=$(echo $OUT | awk '{print $18" "$19" "$20}')

# print debug info and exit if passing DEBUG parameter
case $1 in
    DEBUG)
        echo "WEATHERSYMBOL=$WEATHERSYMBOL"
        echo "WEATHERICON=$WEATHERICON"
        echo "HUMIDITY=$HUMIDITY"
        echo "TEMPERATURE=$TEMPERATURE"
        echo "FEELSLIKE=$FEELSLIKE"
        echo "WIND=$WIND"
        echo "LOCATION=$LOCATION"
        echo "MOONPHASE=$MOONPHASE"
        echo "MOONDAY=$MOONDAY"
        echo "PRECIPITATION=$PRESIPITATION"
        echo "PRESSURE=$PRESSURE"
        echo "DAWN=$DAWN"
        echo "SUNRISE=$SUNRISE"
        echo "ZENITH=$ZENITH"
        echo "SUNSET=$SUNSET"
        echo "DUSK=$DUSK"
        echo "UVINDEX=$UVINDEX"
        echo "WEATHERCONDITION=$WEATHERCONDITION"
        exit 0
esac

# use night icons after sunset and before sunrise
if [ $(date +%s) -gt $(date -d "$SUNRISE" +%s) ] && [ $(date +%s) -lt $(date -d "$SUNSET" +%s) ]; then 
    DAY=1
else
    DAY=0
fi

# parse which icon to use
case $WEATHERSYMBOL in
    "?")    ICON=nodata.png ;;
    "mm")   [[ $DAY -eq 1 ]] && ICON=lightcloud.png || ICON=lightcloud-night.png ;;
    "=")    [[ $DAY -eq 1 ]] && ICON=fog.png || ICON=fog-night.png ;;
    "///")  [[ $DAY -eq 1 ]] && ICON=rain.png || ICON=rain-night.png ;;
    "//")   [[ $DAY -eq 1 ]] && ICON=rain.png || ICON=rain-night.png ;;
    "**")   [[ $DAY -eq 1 ]] && ICON=snow.png || ICON=snow-night.png ;;
    "*/*")  [[ $DAY -eq 1 ]] && ICON=snow.png || ICON=snow-night.png ;;
    "/")    [[ $DAY -eq 1 ]] && ICON=lightrain.png || ICON=lightrain-night.png ;;
    ".")    [[ $DAY -eq 1 ]] && ICON=lightrainsun.png || ICON=lightrainsun-night.png ;;
    "x")    [[ $DAY -eq 1 ]] && ICON=sleet.png || ICON=sleet-night.png ;;
    "x/")   [[ $DAY -eq 1 ]] && ICON=sleetthunder.png || ICON=sleetthunder-night.png ;;
    "*")    [[ $DAY -eq 1 ]] && ICON=snow.png || ICON=snow-night.png ;;
    "*/")   [[ $DAY -eq 1 ]] && ICON=snow.png || ICON=snow-night.png ;;
    "m")    [[ $DAY -eq 1 ]] && ICON=partlycloud.png || ICON=partlycloud-night.png ;;
    "o")    [[ $DAY -eq 1 ]] && ICON=sun.png || ICON=sun-night.png ;;
    "/!/")  [[ $DAY -eq 1 ]] && ICON=rainthunder.png || ICON=rainthunder-night.png ;;
    "!/")   [[ $DAY -eq 1 ]] && ICON=rainthunder.png || ICON=rainthunder-night.png ;;
    "*!*")  [[ $DAY -eq 1 ]] && ICON=snowthunder.png || ICON=snowthunder-night.png ;;
    "mmm")  [[ $DAY -eq 1 ]] && ICON=cloud.png || ICON=cloud-night.png ;;
esac    

# parse uvindex value into text
case $UVINDEX in
    [0-2])          UVSTR="Low" ;;
    [3-5])          UVSTR="Moderate" ;;
    [6-7])          UVSTR="High" ;;
    [8-9]|10)       UVSTR="Very high" ;;
    11|12)          UVSTR="Extreme" ;;
    *)              UVSTR="Unknown" ;;
esac

# parse moon phase in text
case $MOONDAY in
    [0])            MOONSTR="New Moon" ;;
    [1-6])          MOONSTR="Waxing Crescent" ;;
    7)              MOONSTR="First Quarter" ;;
    [8-9]|1[0-5])   MOONSTR="Waxing Gibbous" ;;
    16)             MOONSTR="Full Moon" ;;
    1[7-9]|2[0-2])  MOONSTR="Waning Gibbous" ;;
    23)             MOONSTR="Last Quarter" ;;
    2[4-9])         MOONSTR="Waning Crescent" ;;
    *)              MOONSTR="Unknown" ;;
esac

########################################################################################################################
### GENMON
echo "<img>$ICONS_DIR$ICON</img><txt> $TEMPERATURE</txt>"
echo "<css>.genmon_value {color:white}{</css>"
echo "<click>$CLICK_COMMAND</click>"
echo "<txtclick>$CLICK_COMMAND</txtclick>"
echo -e "<tool><b><big>$SITE</big></b>
$TEMPERATURE <small>and</small> $WEATHERCONDITION

Feels like:\t\t$FEELSLIKE
Humidity:\t\t$HUMIDITY
Wind:\t\t\t$WIND
Precipitation:\t\t$PRECIPITATION
Pressure:\t\t$PRESSURE
UV Index:\t\t$UVINDEX ($UVSTR)

Rise/Set:\t\t$SUNRISE  /  $SUNSET

Moon:\t\t\t$MOONPHASE $MOONSTR

<span size='x-small'>$(date)</span></tool>"

exit 0
