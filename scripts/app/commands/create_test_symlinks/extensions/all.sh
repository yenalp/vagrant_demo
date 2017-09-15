#!/usr/bin/env bash

create_test_symlinks.all.init() {
    create_test_symlinks.all.setup() {
        local __dest_base_path="${1}"

        create_test_symlinks.owner.setup
        create_test_symlinks.symlinks.create "${__dest_base_path}" "owner"
        local -A __features


        create_test_symlinks.facility.setup
        create_test_symlinks.symlinks.create "${__dest_base_path}" "facility"
        local -A __features


        create_test_symlinks.facility.setup
        create_test_symlinks.symlinks.create "${__dest_base_path}" "user"
        local -A __features
    }
}
