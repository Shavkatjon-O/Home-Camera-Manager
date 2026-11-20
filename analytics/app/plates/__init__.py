"""Number plates on vehicle events, in beta.

When a vehicle event happens on a view with plates enabled, the service cuts full-resolution pictures of the vehicle
from the recording buffer, finds the plate with a plate detector, reads it with a text recogniser and votes over
several pictures. The infrared picture at night glares on reflective plates, so grey pictures are not read and the
event says why instead of storing guesses.
"""
