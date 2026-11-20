"""Person re-identification across cameras.

An appearance model embeds the person crops of each track. The embeddings of a track are averaged into one
appearance, and a track that ends is linked to a similar track of another view that ended shortly before, so the
tracks of one person walking through the house join into a journey such as Yard, then Entrance, then Corridor.
"""
