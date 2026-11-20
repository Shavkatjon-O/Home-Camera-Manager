"""Fall detection on the indoor views, in beta.

A pose model finds the body keypoints of every tracked person. A fall is a fast change from an upright posture to
lying, with the hips dropping towards the floor, followed by lying still for a while; lying down slowly on a bed or
a sofa, bending over or crouching does not count.
"""
