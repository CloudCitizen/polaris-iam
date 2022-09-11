import os
import requests
from .base import OIDCClient

BASE_URL = "https://cloudcitizen.okta.com"
PRIVATE_KEY_SECRET = "OKTA_PRIVATE_KEY_SECRET_ARN"


class OktaClient(OIDCClient):
    def __init__(self):
        app_id = os.environ["OKTA_APP_ID"]

        self._extra_jwt_options = {
            "aud": f"{BASE_URL}/oauth2/v1/token",
            "iss": app_id,
            "sub": app_id,
        }

    def _generate_jwt(self):
        return self._generate_jwt_from_private_key(
            self._get_private_key(), self._extra_jwt_options
        )

    def _get_private_key(self):
        return self._get_private_key_from_secret(os.environ[PRIVATE_KEY_SECRET])

    def get_token(self, scopes):
        data = {
            "grant_type": "client_credentials",
            "scope": " ".join(scopes),
            "client_assertion_type": "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
            "client_assertion": self._generate_jwt(),
        }

        response = requests.post(
            f"{BASE_URL}/oauth2/v1/token",
            headers={
                "Accept": "application/json",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            data=data,
        )
        self._check_for_error(response)
        return response.json()["access_token"]
