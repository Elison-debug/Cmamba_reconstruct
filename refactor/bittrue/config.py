from __future__ import annotations

from dataclasses import asdict, dataclass, field
from pathlib import Path
import json
from typing import Any


@dataclass(frozen=True)
class TensorQuantSpec:
    scheme: str
    dtype: str
    bits: int
    granularity: str
    zero_point: str


@dataclass(frozen=True)
class AccumulatorSpec:
    dtype: str
    bits: int
    rounding: str
    saturation: str


@dataclass(frozen=True)
class LUTSpec:
    enabled: bool
    xmin: float
    xmax: float
    entries: int
    interpolation: str


@dataclass(frozen=True)
class NormSpec:
    mode: str
    eps: float = 1e-5


@dataclass(frozen=True)
class BitTrueConfig:
    version: str = "bittrue_v1"
    weights: TensorQuantSpec = field(
        default_factory=lambda: TensorQuantSpec(
            scheme="symmetric",
            dtype="int8",
            bits=8,
            granularity="per_channel",
            zero_point="fixed_zero",
        )
    )
    activations: TensorQuantSpec = field(
        default_factory=lambda: TensorQuantSpec(
            scheme="asymmetric",
            dtype="int8",
            bits=8,
            granularity="per_tensor",
            zero_point="learned_or_calibrated",
        )
    )
    bias: TensorQuantSpec = field(
        default_factory=lambda: TensorQuantSpec(
            scheme="integer",
            dtype="int32",
            bits=32,
            granularity="per_channel",
            zero_point="fixed_zero",
        )
    )
    accumulators: AccumulatorSpec = field(
        default_factory=lambda: AccumulatorSpec(
            dtype="int32",
            bits=32,
            rounding="ties_to_even",
            saturation="clamp",
        )
    )
    requant: AccumulatorSpec = field(
        default_factory=lambda: AccumulatorSpec(
            dtype="int8",
            bits=8,
            rounding="ties_to_even",
            saturation="clamp",
        )
    )
    sigmoid_lut: LUTSpec = field(
        default_factory=lambda: LUTSpec(
            enabled=True,
            xmin=-8.0,
            xmax=8.0,
            entries=4096,
            interpolation="linear",
        )
    )
    silu_lut: LUTSpec = field(
        default_factory=lambda: LUTSpec(
            enabled=True,
            xmin=-8.0,
            xmax=8.0,
            entries=4096,
            interpolation="linear",
        )
    )
    rmsnorm: NormSpec = field(default_factory=lambda: NormSpec(mode="float_reference"))
    notes: list[str] = field(
        default_factory=lambda: [
            "Training/QAT stays in refactor.core and refactor.quant.",
            "This config is for deployment-side bit-true inference only.",
            "The current baseline keeps RMSNorm in float_reference mode.",
            "Exported bit-true packages should embed a copy of this config.",
        ]
    )

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


DEFAULT_CONFIG = BitTrueConfig()


def save_config(path: str | Path, config: BitTrueConfig = DEFAULT_CONFIG) -> Path:
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(config.to_dict(), indent=2), encoding="utf-8")
    return out


__all__ = ["TensorQuantSpec", "AccumulatorSpec", "LUTSpec", "NormSpec", "BitTrueConfig", "DEFAULT_CONFIG", "save_config"]
