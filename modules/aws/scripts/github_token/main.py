from oidc import GithubClient, OktaClient
import json
import boto3
import re
import os
import base64
from botocore.exceptions import ClientError

available_scopes = ("repo_ro", "self", "mgmt")


def lambda_handler(event, context):
    session = boto3.session.Session()

    if not "webIdentityToken" in event:
        return {"statusCode": 400, "message": "Missing webIdentityToken field"}

    if not "scopes" in event:
        return {"statusCode": 400, "message": "Missing scopes field"}

    sts_client = boto3.client("sts")
    response = sts_client.assume_role_with_web_identity(
        RoleArn="arn:aws:iam::860031398530:role/github_token_exchange",
        RoleSessionName="GithubTestTokenClaim",
        WebIdentityToken=event["webIdentityToken"],
        DurationSeconds=900,
    )

    if response["Audience"] != "sts.amazonaws.com":
        return {"statusCode": 400, "message": "Wrong webIdentityToken aud"}

    if (
        response["Provider"]
        != "arn:aws:iam::860031398530:oidc-provider/token.actions.githubusercontent.com"
    ):
        return {"statusCode": 400, "message": "Wrong provider"}

    sub = response["SubjectFromWebIdentityToken"]
    repo_name, job_context, job_context_attr = re.match(
        "repo:CloudCitizen\/([A-Za-z0-9_.-]+):([A-Za-z0-9_.-]+):?(.*)", sub
    ).groups()

    print(
        f"Request from repo {repo_name}, job context {job_context} with attributes {job_context_attr}"
    )

    tokens = {}
    for app_scope in event["scopes"].split(","):

        app, scope = app_scope.split(":", 1)

        if scope not in available_scopes:
            return {
                "statusCode": 400,
                "message": "Scope '%s' not in %s" % (scope, ",".join(available_scopes)),
            }

        if app == "okta":
            oidc_client = OktaClient()

            if scope == "mgmt" and repo_name == "polaris-iam":
                if job_context == "ref" and job_context_attr == "refs/heads/main":
                    requested_scopes = [
                        "okta.users.manage",
                        "okta.groups.manage",
                        "okta.policies.manage",
                        "okta.roles.manage",
                        "okta.apps.manage",
                        "okta.factors.manage",
                    ]
                elif job_context == "pull_request":
                    requested_scopes = [
                        "okta.users.read",
                        "okta.groups.read",
                        "okta.policies.read",
                        "okta.roles.read",
                        "okta.apps.read",
                        "okta.factors.read",
                    ]
                else:
                    return {
                        "statusCode": 403,
                        "message": "Invalid mgmt request for Okta",
                    }

                tokens[app] = oidc_client.get_token(scopes=requested_scopes)
            else:
                return {
                    "statusCode": 403,
                    "message": "Invalid repository or scope for Okta",
                }

        elif app == "github":
            github_org = os.environ["GITHUB_ORG"]
            oidc_client = GithubClient()
            token = oidc_client.get_token(
                github_org, token_request={"permissions": {"metadata": "read"}}
            )
            repos = oidc_client.get_with_pagination(
                f"orgs/{github_org}/repos", token=token
            )

            print(f"Requesting a Github token with scope {scope}")

            # Read-only common repo token
            if scope == "repo_ro":
                request = {
                    "permissions": {
                        "contents": "read",
                    },
                    "repository_ids": [
                        repo["id"]
                        for repo in repos
                        if repo["name"].startswith("tf-module-")
                        or repo["name"] == repo_name
                    ],
                }
            # Self-management token
            elif scope == "self":
                request = {
                    "permissions": {
                        "contents": "write",
                        "pull_requests": "write",
                    },
                    "repository_ids": [
                        repo["id"] for repo in repos if repo["name"] == repo_name
                    ],
                }
            # Manage other repos token
            elif scope == "mgmt":
                if (
                    repo_name == "polaris-iam"
                    and job_context == "ref"
                    and job_context_attr == "refs/heads/main"
                ):
                    request = {
                        "permissions": {
                            "actions": "write",
                            "administration": "write",
                            "contents": "write",
                            "environments": "write",
                            "metadata": "read",
                            "packages": "write",
                            "secrets": "write",
                            "workflows": "write",
                            "members": "write",
                            "organization_hooks": "write",
                            "organization_administration": "write",
                            "organization_secrets": "write",
                            "pages": "write",
                        }
                    }
                elif repo_name == "polaris-iam" and job_context == "pull_request":
                    request = {
                        "permissions": {
                            "actions": "read",
                            "administration": "write",
                            "contents": "read",
                            "environments": "read",
                            "metadata": "read",
                            "packages": "read",
                            "secrets": "read",
                            "workflows": "read",
                            "members": "write",
                            "organization_hooks": "read",
                            "organization_administration": "read",
                            "organization_secrets": "read",
                            "pages": "read",
                        }
                    }
                elif (
                    repo_name.startswith("tf-module-")
                    and job_context == "ref"
                    and job_context_attr == "refs/heads/main"
                ):
                    # Trigger action on another repo for new development in module
                    # tf-module-shared-services can trigger action in wkl-shared-services
                    wkl_repo_name = repo_name.replace("tf-module-", "wkl-", 1)
                    wkl_repos = filter(
                        lambda repo: repo["name"] == wkl_repo_name, repos
                    )

                    try:
                        wkl_repo = next(wkl_repos)
                    except StopIteration:
                        return {
                            "statusCode": 400,
                            "message": "No repos to manage found!",
                        }

                    print("Granting access to repo: " + wkl_repo["full_name"])
                    request = {
                        "permissions": {"contents": "write"},
                        "repository_ids": [wkl_repo["id"]],
                    }
                else:
                    return {
                        "statusCode": 403,
                    }

            tokens[app] = oidc_client.get_token(
                github_org, token_request=request)
        else:
            return {
                "statusCode": 400,
                "message": f"App '{app}' not known",
            }

    return {
        "statusCode": 200,
        "tokens": tokens,
    }
