"""This is a test file."""


def double(x: int) -> int:
    """Double the input."""
    breakpoint()
    return x * 2


VAL = 3
print(f"{VAL} * 2 is {double(VAL)}")
