"""PTZ auto-follow: keeps a tracked person centred on a moving lens and returns the lens afterwards.

The controller is pure logic that turns the tracked boxes of one view into pan and tilt commands. A mover carries the
commands out through the backend, and the recording mover remembers where the lens started so it can go back, by a
preset where the camera keeps one and by retracing its moves where it keeps none. Follow is off by default, because
the owner decides whether the cameras may move by themselves.
"""
