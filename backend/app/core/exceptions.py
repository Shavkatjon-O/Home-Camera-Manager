"""Service errors that carry an error code and the HTTP status they map to."""


class ServiceError(Exception):
    """Error a service raises for the API to return to the client.

    Attributes:
        status_code: HTTP status the error maps to.
        code: Stable machine-readable error code.
        message: Human-readable explanation.
    """

    status_code = 400

    def __init__(self, code: str, message: str):
        """Create the error.

        Args:
            code: Stable machine-readable error code.
            message: Human-readable explanation.
        """
        super().__init__(message)
        self.code = code
        self.message = message


class BadRequest(ServiceError):
    """The request is malformed.

    Attributes:
        status_code: HTTP status 400.
    """

    status_code = 400


class Unauthorized(ServiceError):
    """The request has no valid credentials.

    Attributes:
        status_code: HTTP status 401.
    """

    status_code = 401


class NotFound(ServiceError):
    """The requested item does not exist.

    Attributes:
        status_code: HTTP status 404.
    """

    status_code = 404


class Conflict(ServiceError):
    """The request conflicts with the current state.

    Attributes:
        status_code: HTTP status 409.
    """

    status_code = 409


class Unprocessable(ServiceError):
    """The request is well formed but cannot be carried out.

    Attributes:
        status_code: HTTP status 422.
    """

    status_code = 422


class TooManyRequests(ServiceError):
    """The client has sent too many requests.

    Attributes:
        status_code: HTTP status 429.
    """

    status_code = 429


class BadGateway(ServiceError):
    """A camera, bridge or go2rtc did not answer properly.

    Attributes:
        status_code: HTTP status 502.
    """

    status_code = 502


class Unavailable(ServiceError):
    """The request cannot be served right now.

    Attributes:
        status_code: HTTP status 503.
    """

    status_code = 503
