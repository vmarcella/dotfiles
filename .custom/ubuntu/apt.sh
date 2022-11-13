#!/bin/bash

# Update the package lists and show the packages that can be upgraded.
update_and_show_packages() {
    (
        set -e
        sudo apt update
        apt list --upgradable
    )
}
