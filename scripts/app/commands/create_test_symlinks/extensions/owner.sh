#!/usr/bin/env bash

create_test_symlinks.owner.init() {
    create_test_symlinks.owner.setup() {
        # Release 0.0.2
        local __base_path="0.0.2/admin/owner"
        __features['admin-owner-edit']="${__base_path}/admin-owner-edit.feature"
        __features['admin-owner-list']="${__base_path}/admin-owner-list.feature"
        __features['admin-owner-view']="${__base_path}/admin-owner-view.feature"

        __base_path="0.0.2/admin/owner/category"
        __features['admin-owner-category-remove']="${__base_path}/admin-owner-category-remove.feature"

        # Release 0.0.4
        __base_path="0.0.4/owner"
        __features['admin-owner-create']="${__base_path}/admin-owner-create.feature"
        __features['admin-owner-archive']="${__base_path}/admin-owner-archive.feature"

        __base_path="0.0.4/owner/category"
        __features['admin-owner-category-create']="${__base_path}/admin-owner-category-create.feature"
    }
}
