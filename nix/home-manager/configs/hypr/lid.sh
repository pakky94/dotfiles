#!/bin/sh

TARGET=$1

if [[ $# == 0 ]]; then
  TARGET=$(awk -F: '{ gsub(/ /,""); print $2 }' /proc/acpi/button/lid/LID0/state)
fi

echo $TARGET

if [[ $TARGET == "open" ]]; then
  hyprctl keyword "\$LID_OPENED" true && hyprctl keyword device:a ""
  # hyprctl keyword "\$LID_OPENED" true -r
  # echo "open" > ~/test1
  # hyprctl keyword "\$LID_OPENED" false && hyprctl keyword device:a ""
else
  hyprctl keyword "\$LID_OPENED" false && hyprctl keyword device:a ""
  # hyprctl keyword "\$LID_OPENED" false -r
  # echo "closed" > ~/test1
  # hyprctl keyword "\$LID_OPENED" true && hyprctl keyword device:a ""
fi
