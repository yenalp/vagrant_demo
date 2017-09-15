#!/usr/bin/env bash

create_test_symlinks.facility.init() {
    create_test_symlinks.facility.setup() {
        # Release 0.0.2
        local __base_path="0.0.2/admin/facility"
        __features['admin-facility-archive']="${__base_path}/admin-facility-archive.feature"
        __features['admin-facility-create']="${__base_path}/admin-facility-create.feature"
        __features['admin-facility-edit']="${__base_path}/admin-facility-edit.feature"
        __features['admin-facility-view']="${__base_path}/admin-facility-view.feature"

        __base_path="0.0.2/admin/facility/benchmarks"
        __features['admin-facility-benchmarks-create']="${__base_path}/admin-facility-benchmarks-create.feature"
        __features['admin-facility-benchmarks-delete']="${__base_path}/admin-facility-benchmarks-delete.feature"
        __features['admin-facility-benchmarks-edit']="${__base_path}/admin-facility-benchmarks-edit.feature"

        # Release 0.0.4
        __base_path="0.0.4/facility"
        __features['admin-facility-list']="${__base_path}/admin-facility-list.feature"

        # Release 0.0.5
        __base_path="0.0.5/Admin_Site/facility"
        __features['admin-facility-add']="${__base_path}/admin-facility-department-add.feature"
        __features['admin-facility-department-type-manage']="${__base_path}/admin-facility-department-type-manage.feature"
    }
}
