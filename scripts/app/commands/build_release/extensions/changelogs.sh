#!/usr/bin/env bash

build_release.changelogs.init() {
    build_release.changelogs.generate() {
        logger.info --message \
            'Generating change logs...'

        cd "${__ui_repo_path}"
        local __ui_changelog=$(git log --pretty=format:'* %s')
        local __changelog="${__ui_changelog}"
        local __new_version="${__branch_name}"
        build_release.changelogs.template  > "${__release_path}/ui/CHANGELOG.md"


        cd "${__api_repo_path}"
        __api_changelog=$(git log --pretty=format:'* %s')
        local __changelog="${__api_changelog}"
        __new_version="${__branch_name}"
        build_release.changelogs.template  > "${__release_path}/api/CHANGELOG.md"
    }

    build_release.changelogs.template() {
        cat << EOF | mo
# Version {{__new_version}}

## Changelog

{{__changelog}}
EOF
    }
}