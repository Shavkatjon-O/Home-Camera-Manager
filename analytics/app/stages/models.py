"""The models of the secondary stages and where they live in the model folder.

scripts/download-secondary-models.sh downloads every file listed here with the same digest. A model names its file
inside the model root, so the same definition works on any host that mounts the model layer.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class StageModel:
    """One secondary model and how its engine is built.

    Attributes:
        name: Stable identifier used for the engine cache and the status endpoint.
        family: Folder of the model family inside the model root.
        onnx: ONNX file name inside the family's version folder.
        sha256: Published digest of the ONNX file, checked before TensorRT parses it.
        input_shape: Channels, height and width the engine is built for.
        batch: Largest batch the engine accepts.
        precision: Engine precision, fp16 or fp32.
        licence: Licence of the weights, shown by the status endpoint.
        version: Version folder inside the family folder.
    """

    name: str
    family: str
    onnx: str
    sha256: str
    input_shape: tuple[int, int, int]
    batch: int
    precision: str = "fp16"
    licence: str = ""
    version: str = "v1"

    def path(self, model_root: Path) -> Path:
        """Return the ONNX file of this model inside the model root.

        Args:
            model_root: Folder holding one sub folder per model family.

        Returns:
            The ONNX path.
        """
        return model_root / self.family / self.version / self.onnx


REID = StageModel(
    name="osnet-ain-x1",
    family="osnet",
    onnx="osnet_ain_x1_0_msmt17.onnx",
    sha256="f11a8fa82c3980f13f563210ddf197346bbd8d1bd0dca364c4ad6c4e39794116",
    input_shape=(3, 256, 128),
    batch=16,
    licence="MIT",
)

POSE = StageModel(
    name="rtmpose-m",
    family="rtmpose",
    onnx="rtmpose-m-body7-256x192.onnx",
    sha256="5c0a4bf67953e6d2ac43ce15e77dc9d5d354ae18430a47d2c5963a7bc5683e3c",
    input_shape=(3, 256, 192),
    batch=8,
    licence="Apache-2.0",
)

PLATE_DETECTOR = StageModel(
    name="lpdnet-usa",
    family="lpdnet",
    onnx="LPDNet_usa_pruned_tao5.onnx",
    sha256="8174ff09e316ec9fcc74ff0947bc73536a6f25a33aae1c52e9effab8a91c7930",
    input_shape=(3, 480, 640),
    batch=8,
    licence="NVIDIA AI Enterprise EULA, commercial use stated on the model card",
)

PLATE_TEXT = StageModel(
    name="ppocr-v4-det",
    family="paddleocr",
    onnx="ch_PP-OCRv4_det_mobile.onnx",
    sha256="d2a7720d45a54257208b1e13e36a8479894cb74155a5efe29462512d42f49da9",
    input_shape=(3, 480, 640),
    batch=1,
    licence="Apache-2.0",
)

PLATE_READER = StageModel(
    name="ppocr-v4-en",
    family="paddleocr",
    onnx="en_PP-OCRv4_rec_mobile.onnx",
    sha256="e8770c967605983d1570cdf5352041dfb68fa0c21664f49f47b155abd3e0e318",
    input_shape=(3, 48, 320),
    batch=8,
    licence="Apache-2.0",
)

PLATE_DICTIONARY = "en_dict.txt"
PLATE_DICTIONARY_SHA256 = "5662df9d2d03f0e8ca0d3b0649d6acbab904b6a14b3d3521463c71c37c668ce3"

MODELS = {model.name: model for model in (REID, POSE, PLATE_TEXT, PLATE_DETECTOR, PLATE_READER)}
