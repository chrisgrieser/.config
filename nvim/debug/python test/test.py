"""This is a test file."""




def myfun() -> int: # pyright: ignore [reportGeneralTypeIssues]
    """Test."""
    f_f = 20
    if f_f == 20:
        f_f = 10
    print(f_f)


def hello() -> int:
    """Test."""
