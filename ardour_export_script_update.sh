#!/bin/bash

echo "change options in ardour_export_script"
sed -i -e 's/-m s/-m j/g' .local/bin/ardour_export_to_mp3_st_192_gain_89.sh
sed -i -e 's/-o -S /-o -S --noreplaygain /g' .local/bin/ardour_export_to_mp3_st_192_gain_89.sh
sed -i -e 's/mp3gain -r /mp3gain /g' .local/bin/ardour_export_to_mp3_st_192_gain_89.sh
echo "finito"
exit
