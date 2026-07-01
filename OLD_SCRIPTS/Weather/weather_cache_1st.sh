#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Mon 24. Nov 2025
#
# Purpose:      Fetch data from wttr.in and save it into a text file.
#               New data will only be requested when one of the two conditions:
#               1. No data exists
#               2. Data is older than optimal
#               This script is tailored towards fastfetch and conky.
# =============================================================================

weather_params="Garching?format=%l:+%c+(%f)+%t+%p"
data_path="/home/akash/Scripts/Weather/data_weather_1.txt"
duration=3600
conn_time=60
max_time=60

getWeather() {
    if [[ -e "$data_path" ]]; then
        weather_date="$(stat -c '%Y' "$data_path")"
        current_date="$(date +%s)"
        date_diff=$(($current_date - $weather_date))

        if [ "$date_diff" -ge $duration ]; then
            getWeatherData
            setWeatherData
        else
            setWeatherData
        fi
    else
        getWeatherData
        setWeatherData
    fi

    showWeatherData
}
getWeatherData() {
    # curl -s --connect-timeout $conn_time -m $max_time "https://wttr.in/$weather_params" > "$data_path" || quit 'service unreachable'
    # curl -s --connect-timeout $conn_time -m $max_time "http://wttr.in/$weather_params" > "$data_path" || quit 'service unreachable'
    curl -s --connect-timeout $conn_time -m $max_time "wttr.in/$weather_params" > "$data_path" || quit 'service unreachable'
}
setWeatherData() {
    weather_data="$(cat "$data_path")"
}
showWeatherData() {
    echo "$weather_data"
}
quit() {
    if [[ "$1" = 0 ]]
    then
            exit 0
    else
            # echo "$1" > "$data_path"
            printf "%b\n" "$1"
            exit 1
    fi
}
getWeather
quit 0
