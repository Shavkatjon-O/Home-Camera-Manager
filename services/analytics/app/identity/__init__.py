"""Face recognition for the identity profile.

SCRFD finds faces inside the pipeline on the person objects of identity views, the pipeline process aligns the best
faces of each track, and the service process embeds them with glintr100, averages them per track, matches the track
against the gallery of known people and groups unknown faces into clusters.
"""
