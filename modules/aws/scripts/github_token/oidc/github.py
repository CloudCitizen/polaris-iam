import os
import requests
from functools import partialmethod
from .base import OIDCClient

BASE_URL = "https://api.github.com"
PRIVATE_KEY_SECRET = "GITHUB_PRIVATE_KEY_SECRET_ARN"


class GithubClient(OIDCClient):
    def __init__(self):
        app_id = os.environ["GITHUB_APP_ID"]

        self._extra_jwt_options = {
            "iss": app_id,
        }
        self._extra_headers = {"Accept": "application/vnd.github.v3+json"}

    def _generate_jwt(self):
        return self._generate_jwt_from_private_key(
            self._get_private_key(), self._extra_jwt_options
        )

    def _get_private_key(self):
        return self._get_private_key_from_secret(os.environ[PRIVATE_KEY_SECRET])

    def _call(self, func, path, *args, **kwargs):
        token = kwargs.pop("token", None)
        if token is not None:
            auth = f"token {token}"
        else:
            encoded_jwt = self._generate_jwt()
            auth = f"Bearer {encoded_jwt}"

        headers = kwargs.get("headers", {})
        headers.update({"Authorization": auth, **self._extra_headers})
        kwargs["headers"] = headers
        response = func(f"{BASE_URL}/{path}", *args, **kwargs)
        self._check_for_error(response)
        return response.json()

    get = partialmethod(_call, requests.get)
    post = partialmethod(_call, requests.post)

    def get_with_pagination(self, *args, **kwargs):
        response = []
        params = kwargs.get("params", {})
        params["page"] = 1
        kwargs["params"] = params
        while r := self.get(*args, **kwargs):
            response.extend(r)
            params["page"] += 1
        return response

    def get_token(self, github_org, token_request):
        installation_res = self.get(f"app/installations")
        installation_id = next(
            filter(
                lambda installation: installation["account"]["login"] == github_org,
                installation_res,
            )
        )["id"]
        token_res = self.post(
            f"app/installations/{installation_id}/access_tokens", json=token_request
        )
        return token_res["token"]
