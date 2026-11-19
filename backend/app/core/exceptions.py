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
    """The request is malformed."""

    status_code = 400


class Unauthorized(ServiceError):
    """The request has no valid credentials."""

    status_code = 401


class NotFound(ServiceError):
    """The requested item does not exist."""

    status_code = 404


class Conflict(ServiceError):
    """The request conflicts with the current state."""

    status_code = 409


class Unprocessable(ServiceError):
    """The request is well formed but cannot be carried out."""

    status_code = 422


class TooManyRequests(ServiceError):
    """The client has sent too many requests."""

    status_code = 429


class BadGateway(ServiceError):
    """A camera, bridge or go2rtc did not answer properly."""

    status_code = 502


class Unavailable(ServiceError):
    """The request cannot be served right now."""

    status_code = 503
