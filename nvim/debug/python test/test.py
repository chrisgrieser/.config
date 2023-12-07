"""This is a test file."""

import sys
import time


def double(x: int) -> int:
    """Double the number.

    Args:
        x: input

    Returns:
        doubled number
    """
    return x * 2


a = 6
print(double(a))
