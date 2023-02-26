#!/bin/bash

set -x

TMP=tmp_repo
repos="DO280-apps"
gb_userpass='root:root'
gitbucket_url="gitbucket.apps.dshirley1ipi.vmware.tamlab.rdu2.redhat.com"
gitbucket_user="root"

for repo in `echo $repos`; do
    echo "--- Migrating $repo"
    rm -rf $TMP

    # clone from source
    git clone --mirror https://github.com/dshirley-redhat/$repo $TMP

    # create the repo on gitbucket
    http --verify=no --auth $gb_userpass POST https://$gitbucket_url/api/v3/orgs/$gitbucket_user/repos name=$repo

    # push to gitbucket
    pushd $TMP
    git remote set-url origin https://root:root@$gitbucket_url/$gitbucket_user/$repo.git
    git push origin --mirror -f

    popd && rm -rf $TMP
done