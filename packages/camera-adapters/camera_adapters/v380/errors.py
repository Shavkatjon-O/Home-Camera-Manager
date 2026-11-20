"""Errors of the V380 LAN protocol client."""

__all__ = [
    "FramingLost",
    "LoginRefused",
    "ProtocolError",
    "ReplyTimeout",
    "SessionLost",
    "StreamRefused",
    "Unreachable",
    "V380Error",
]


class V380Error(Exception):
    """A V380 session could not be opened or kept.

    Attributes:
        code: Stable code shared with the adapter errors: unreachable, unauthorized, invalid or no_stream.
        message: Explanation.
    """

    code = "no_stream"

    def __init__(self, message: str):
        """Create the error.

        Args:
            message: Explanation.
        """
        super().__init__(message)
        self.message = message


class Unreachable(V380Error):
    """The camera did not accept a connection in time."""

    code = "unreachable"


class ReplyTimeout(V380Error):
    """The camera sent no reply in time."""

    code = "unreachable"


class ProtocolError(V380Error):
    """A reply was missing, short or of another command."""

    code = "invalid"


class LoginRefused(V380Error):
    """The camera refused the login.

    Attributes:
        result: Result code of the login reply.
    """

    code = "unauthorized"

    def __init__(self, result: int):
        """Create the error from the login result.

        Args:
            result: Result code of the login reply.
        """
        reasons = {1011: "unknown user name", 1012: "wrong password", 1018: "wrong device id"}
        super().__init__(f"The camera refused the login: {reasons.get(result, f'result {result}')}")
        self.result = result


class StreamRefused(V380Error):
    """The camera refused the stream login.

    Attributes:
        result: Result code of the stream login reply.
    """

    def __init__(self, result: int):
        """Create the error from the stream login result.

        Args:
            result: Result code of the stream login reply.
        """
        super().__init__(f"The camera refused the stream login with result {result}")
        self.result = result


class SessionLost(V380Error):
    """The stream connection closed or went silent."""


class FramingLost(SessionLost):
    """Too many consecutive invalid fragment headers arrived to keep the framing."""
