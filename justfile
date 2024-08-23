output_dir := "build"
package_name := "fletchart"

build version: clean
    #!/usr/bin/env bash
    set -euo pipefail

    out_dir={{output_dir}}
    mkdir -p "$out_dir/src"
    cp -r "src/" "README.md" "typst.toml" $out_dir
    echo "Resources copied."

    just _file_substitute "{{{{VERSION}}" {{version}} $out_dir
    echo "Version updated."
    echo "Built {{package_name}} version {{version}}."

install version: (build version)
    #!/usr/bin/env bash
    set -euo pipefail
    install_dir=~/.local/share/typst/packages/local/{{package_name / version}}
    mkdir -p $install_dir
    cp -r {{output_dir}}/* $install_dir
    echo "Installed {{package_name}} version {{version}}."

clean:
    rm -r {{output_dir}} || true
    @echo "Cleaned {{package_name}}."

_file_substitute from to directory:
    #!/usr/bin/env bash
    set -euo pipefail

    for file in {{directory / "*"}}; do
        if [ -d "$file" ]; then
            just _file_substitute {{from}} {{to}} $file
        elif grep -Iq . "$file"; then
            # means the file is not a binary file
            set +e
            occ=$(grep -o {{from}} $file | wc -l)
            set -e
            echo "Substituting $occ occurences of {{from}} in $file."
            sed -i {{"s"/from/to/"g"}} $file
        fi
    done