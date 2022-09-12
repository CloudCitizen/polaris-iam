import jwt
import datetime
import boto3
from functools import partialmethod


class OIDCClient(object):
    def _get_private_key_from_secret(self, secret_id):
        sm_client = boto3.client("secretsmanager", region_name="eu-central-1")
        get_secret_value_response = sm_client.get_secret_value(SecretId=secret_id)
        private_key = get_secret_value_response["SecretString"]
        return private_key

    def _generate_jwt_from_private_key(self, private_key, extra_jwt_options):
        payload = {
            "iat": datetime.datetime.now(tz=datetime.timezone.utc)
            - datetime.timedelta(seconds=30),
            "exp": datetime.datetime.now(tz=datetime.timezone.utc)
            + datetime.timedelta(seconds=120),
            **extra_jwt_options,
        }

        return jwt.encode(payload, private_key, algorithm="RS256")

    def _check_for_error(self, response):
        if not response.ok:
            raise Exception(
                "OIDC request failed with status code %s - %s"
                % (response.status_code, response.json())
            )
