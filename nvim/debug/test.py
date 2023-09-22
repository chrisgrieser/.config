"""This is a test file."""


import os
from random import seed


def myfun(one: int, two: int) -> int:
    """Test."""
    return one * three     # pyright: ignore reportUndefinedVariable

def hello() -> None:
    """Test."""
    numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    used_numbers = []

    print("hello world")


    the_sum = 0
    for numb in numbers:
        the_sum += numb # pyright: ignore reportUnboundVariable
        the_sum = the_sum / 2
        used_numbers.append(numb)

    print(the_sum)


hello()
