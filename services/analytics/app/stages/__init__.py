"""Secondary inference stages that run on tracked objects after the tracker.

Person re-identification, body pose and number plates each run as a secondary nvinfer on the objects the shared
detector found. This package holds what they share: the model registry, the TensorRT engine cache and the nvinfer
configuration writer.
"""
