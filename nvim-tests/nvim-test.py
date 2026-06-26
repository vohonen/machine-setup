"""Quick scratch file to sanity-check treesitter highlighting + textobjects."""

import math
from dataclasses import dataclass


@dataclass
class Vec2:
    x: float
    y: float

    def norm(self) -> float:
        # put the cursor inside this function and try  vif / vaf / cif
        return math.sqrt(self.x**2 + self.y**2)


def normalize(v: Vec2) -> Vec2:
    n = v.norm()
    if n == 0:
        raise ValueError("cannot normalize zero vector")
    return Vec2(v.x / n, v.y / n)


if __name__ == "__main__":
    for vec in (Vec2(3, 4), Vec2(1, 0), Vec2(0, 0)):
        try:
            print(f"{vec} -> norm={vec.norm():.3f} -> {normalize(vec)}")
        except ValueError as e:
            print(f"{vec}: {e}")
