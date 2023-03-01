#!/bin/bash

set -x

TMP=tmp_repo
developer_argo_webhook_url="developer-gitops-server-developer-gitops.apps.dshirley1ipi.vmware.tamlab.rdu2.redhat.com"

for repo in `echo $import_repos`; do
    echo "--- Migrating $repo"
    rm -rf $TMP

    # clone from source
    git clone --mirror https://github.com/dshirley-redhat/$repo $TMP

    # create the repo on gitbucket
    http --verify=no --ignore-stdin --auth $gitbucket_user:$gitbucket_password POST \
        https://$gitbucket_url/api/v3/orgs/$gitbucket_user/repos name=$repo

    curl -u $gitbucket_user:$gitbucket_password \
        --insecure \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://$gitbucket_url/api/v3/repos/$gitbucket_user/$repo/hooks \
        -d '{"name":"developer-gitops","active":true,"events":["push"],"config":{"url":"https://'$developer_argo_webhook_url'","content_type":"json","insecure_ssl":"1"}}'

    # push to gitbucket
    pushd $TMP
    git remote set-url origin https://$gitbucket_user:$gitbucket_password@$gitbucket_url/$gitbucket_user/$repo.git
    git -c http.sslVerify=false push origin --mirror -f

    popd && rm -rf $TMP
done
