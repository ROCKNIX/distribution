#!/bin/bash

desc2dtso() {
cat << EOH
/dts-v1/;
/plugin/;

// compile with \`dtc -@ -I dts -O dtb -o mipi-panel.dtbo elida-kd35t133.dtso\`

/ {
  fragment@0 {
    target-path = "/dsi@ff450000/panel@0";
    __overlay__ {
      compatible = "rocknix,generic-dsi";
      panel_description =
EOH

sed 's|^\(..*\)$|        "\1",|' $1

cat << EOF
        "#END";
    };
  };
};
EOF
}

desc2dtso $1 | dtc -I dts -O dtb
