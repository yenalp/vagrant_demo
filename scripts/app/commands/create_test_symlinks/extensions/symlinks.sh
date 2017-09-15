#!/usr/bin/env bash

create_test_symlinks.symlinks.init() {
    create_test_symlinks.symlinks.create() {
        local __test_dir="$1"
        local __component="$2"
        local __feature_length="${#__features[@]}"

        logger.beginTask --message \
            "Creating Symlinks"


        logger.step --message \
            "Removing Symlinks" \
            --number "1" \
            --total "2"

        # remove symlinks in component directory
        create_test_symlinks.symlinks.removeSymlinks \
            "${__test_dir}/${__component}"


        logger.step --message \
            "Adding features" \
            --number "2" \
            --total "2"

        local __i
        local __feature_counter=1
        for __i in "${!__features[@]}"; do
            local __key="${__i}"
            local __feature_path="${__features[${__key}]}"
            local __source_path="${__test_dir}/${__feature_path}"
            local __dest_path="${__test_dir}/${__component}/${__key}.feature"

            logger.step --message \
                "Adding feature \"${__key}\"" \
                --number "2-${__feature_counter}" \
                --total "${__feature_length}"

            logger.info --message \
                "Source Path: ${__source_path}"

            logger.info --message \
                "Dest Path: ${__dest_path}"

            ln -s "${__source_path}" "${__dest_path}" || {
                logger.warning --message \
                    "Not good - could not create symbolic link"
            }

            logger.info --message \
                "Dest Path: ${__dest_path}"

            ((__feature_counter++))
        done

        logger.endTask --message \
            "Creating Symlinks"

    }

    create_test_symlinks.symlinks.removeSymlinks() {
        local __line
        find "$1" -name '*.feature' -type l | while read __line
            do
                rm -v "${__line}" || {
                    logger.warning --message \
                        "Could not remove symbolic ${$i}/${__line}"
                }
        done

    }

}
