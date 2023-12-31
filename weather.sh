#!/bin/bash
# genmon script to query and display weather data from wttr.in (https://github.com/chubin/wttr.in)
# requires: curl & weather icons (https://github.com/kevin-hanselman/xfce4-weather-mono-icons)
# Note: depending on the font your are using, you may need to adjust the number of "\t" (tabs) 
#       in the tooltip string to get the readings to line up properly.
# Script calls:
#   weather.sh DEBUG                        # for debug output
#   weather.sh SITENAME LATITUDE LONGITUDE  # regular use

########################################################################################################################
### CONFIGURATION - CHANGE THESE VALUES TO SUIT
#
# ensure 3 parameters are passed to script:
#   1 = Site/City name - to be displayed in tooltip
#   2 = Latitude coordinate
#   3 = Longitude coordinate
SITE="$1"
LATITUDE="$2"
LONGITUDE="$3"

UNIT="m"                            # options: u=USCS, m=metric, M=metric with wind speed in m/s
#CLICK_COMMAND="xdotool key F12"     # what executes when you click on plugin - options below
CLICK_COMMAND="xfce4-terminal -H --geometry=126x41 -T Weather -x curl -s wttr.in/$LATITUDE,$LONGITUDE"

########################################################################################################################
### SCRIPT GLOBALS
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ICONS_DIR="$SCRIPT_DIR/weather-icons/22/"

########################################################################################################################
### CODE 

# parse time display to -l:M P
function toTime
{
	echo "$(date -d $1 '+%-l:%M %P')"
}

# strip out + and -0 from temperature strings
function strip
{
    echo "$1" | sed -e 's/+//g' | sed -e 's/^-0/0/g'
}

# add a space between measurement and unit
function separate
{
    echo "$1" | sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g'
}

# get the weather data and put into an array
OUT=( $(curl -s wttr.in/$LATITUDE,$LONGITUDE?$UNIT\&format="%x\n%c\n%h\n%t\n%f\n%w\n%l\n%m\n%M\n%p\n%P\n%D\n%S\n%z\n%s\n%d\n%u\n%C\n"\&nonce=$RANDOM) )

# parse the weather data
WEATHERSYMBOL=${OUT[@]:0:1}
WEATHERICON=${OUT[@]:1:1}
HUMIDITY=${OUT[@]:2:1}
TEMPERATURE=$(strip ${OUT[@]:3:1})
FEELSLIKE=$(strip ${OUT[@]:4:1})
WIND=$(separate ${OUT[@]:5:1})
LOCATION=${OUT[@]:6:1}
MOONPHASE=${OUT[@]:7:1}
MOONDAY=${OUT[@]:8:1}
PRECIPITATION=$(separate ${OUT[@]:9:1})
PRESSURE=$(separate ${OUT[@]:10:1})
DAWN=$(toTime ${OUT[@]:11:1})
SUNRISE=$(toTime ${OUT[@]:12:1})
ZENITH=$(toTime ${OUT[@]:13:1})
SUNSET=$(toTime ${OUT[@]:14:1})
DUSK=$(toTime ${OUT[@]:15:1})
UVINDEX=${OUT[@]:16:1}
WEATHERCONDITION=${OUT[@]:17:3}

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
    "mm")   [[ $DAY -eq 1 ]] && ICON=lightcloud.png     || ICON=lightcloud-night.png    ;;
    "=")    [[ $DAY -eq 1 ]] && ICON=fog.png            || ICON=fog-night.png           ;;
    "///")  [[ $DAY -eq 1 ]] && ICON=rain.png           || ICON=rain-night.png          ;;
    "//")   [[ $DAY -eq 1 ]] && ICON=rain.png           || ICON=rain-night.png          ;;
    "**")   [[ $DAY -eq 1 ]] && ICON=snow.png           || ICON=snow-night.png          ;;
    "*/*")  [[ $DAY -eq 1 ]] && ICON=snow.png           || ICON=snow-night.png          ;;
    "/")    [[ $DAY -eq 1 ]] && ICON=lightrain.png      || ICON=lightrain-night.png     ;;
    ".")    [[ $DAY -eq 1 ]] && ICON=lightrainsun.png   || ICON=lightrainsun-night.png  ;;
    "x")    [[ $DAY -eq 1 ]] && ICON=sleet.png          || ICON=sleet-night.png         ;;
    "x/")   [[ $DAY -eq 1 ]] && ICON=sleetthunder.png   || ICON=sleetthunder-night.png  ;;
    "*")    [[ $DAY -eq 1 ]] && ICON=snow.png           || ICON=snow-night.png          ;;
    "*/")   [[ $DAY -eq 1 ]] && ICON=snow.png           || ICON=snow-night.png          ;;
    "m")    [[ $DAY -eq 1 ]] && ICON=partlycloud.png    || ICON=partlycloud-night.png   ;;
    "o")    [[ $DAY -eq 1 ]] && ICON=sun.png            || ICON=sun-night.png           ;;
    "/!/")  [[ $DAY -eq 1 ]] && ICON=rainthunder.png    || ICON=rainthunder-night.png   ;;
    "!/")   [[ $DAY -eq 1 ]] && ICON=rainthunder.png    || ICON=rainthunder-night.png   ;;
    "*!*")  [[ $DAY -eq 1 ]] && ICON=snowthunder.png    || ICON=snowthunder-night.png   ;;
    "mmm")  [[ $DAY -eq 1 ]] && ICON=cloud.png          || ICON=cloud-night.png         ;;
esac    

# parse uvindex value into text
case $UVINDEX in
    [0-2])          UVSTR="Low"         ;;
    [3-5])          UVSTR="Moderate"    ;;
    [6-7])          UVSTR="High"        ;;
    [8-9]|10)       UVSTR="Very high"   ;;
    11|12)          UVSTR="Extreme"     ;;
    *)              UVSTR="Unknown"     ;;
esac

# parse moon phase in text
case $MOONDAY in
    [0])            MOONSTR="New Moon"          ;;
    [1-6])          MOONSTR="Waxing Crescent"   ;;
    7)              MOONSTR="First Quarter"     ;;
    [8-9]|1[0-5])   MOONSTR="Waxing Gibbous"    ;;
    16)             MOONSTR="Full Moon"         ;;
    1[7-9]|2[0-2])  MOONSTR="Waning Gibbous"    ;;
    23)             MOONSTR="Last Quarter"      ;;
    2[4-9])         MOONSTR="Waning Crescent"   ;;
    *)              MOONSTR="Unknown"           ;;
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
