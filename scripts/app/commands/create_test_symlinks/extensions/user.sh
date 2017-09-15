#!/usr/bin/env bash

create_test_symlinks.user.init() {
    create_test_symlinks.user.setup() {
        # Release 0.0.2
        local __base_path="0.0.2/admin/user"
        __features['admin-user-delete-user-account']="${__base_path}/admin-user-delete-user-account.feature"
        __features['admin-user-edit-user-account']="${__base_path}/admin-user-edit-user-account.feature"
        __features['admin-user-enable-user-account']="${__base_path}/admin-user-enable-user-account.feature"
        __features['admin-user-search-user-accounts']="${__base_path}/admin-user-search-user-accounts.feature"
        __features['admin-user-view-user-account']="${__base_path}/admin-user-view-user-account.feature"

        # Release 0.0.4
        __base_path="0.0.4/user"
        __features['admin-user-create-user-account']="${__base_path}/admin-user-create-user-account.feature"
        __features['admin-user-disable-user-account']="${__base_path}/admin-user-disable-user-account.feature"

        # Release 0.0.5
        __base_path="0.0.5/Admin_Site/users"
        __features['admin-users-login-as-another-user']="${__base_path}/admin-users-login-as-another-user.feature"
        __features['admin-users-password-reset-account']="${__base_path}/admin-users-password-reset-account.feature"
        __features['admin-users-password-reset-link']="${__base_path}/admin-users-password-reset-link.feature"
        __features['admin-users-password-send-reset']="${__base_path}/admin-users-password-send-reset.feature"
        __features['admin-users-password-set']="${__base_path}/admin-users-password-set.feature"

        # Release 0.0.5 --- Yet to be implemented
        # __base_path="0.0.7/Admin_Site/users"
        # __features['admin-users-password-expriry']="${__base_path}/admin-users-password-expriry.template"

    }
}
