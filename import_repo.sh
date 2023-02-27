#!/bin/bash

set -x

TMP=tmp_repo
developer_argo_webhook_url="developer-gitops-server-developer-gitops.apps.dshirley1ipi.vmware.tamlab.rdu2.redhat.com"
 
cd /tmp

for repo in `echo $import_repos`; do
    echo "--- Migrating $repo"
    rm -rf $TMP

    # clone from source
    git clone --mirror https://github.com/dshirley-redhat/$repo $TMP

    # create the repo on gitbucket
    http --verify=no --ignore-stdin --auth $gitbucket_user:$gitbucket_password POST \
        https://$gitbucket_url/api/v3/orgs/$gitbucket_user/repos name=$repo

    http --verify=no --ignore-stdin --auth $gitbucket_user:$gitbucket_password POST \
        https://$gitbucket_url/api/v3/orgs/$gitbucket_user/$repo/hooks \
        '{"name":"web","active":true,"events":["push","pull_request"],"config":{"url":'https://$developer_argo_webhook_url/api/webhook',"content_type":"json","insecure_ssl":"0"}}'
 
    # push to gitbucket
    pushd $TMP
    git remote set-url origin https://$gitbucket_user:$gitbucket_password@$gitbucket_url/$gitbucket_user/$repo.git
    git -c http.sslVerify=false push origin --mirror -f

    popd && rm -rf $TMP
done
