"""This is a test file."""

numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
used_numbers = []

summ = 0
for numb in numbers:
    summ += numb
    summ = summ / 2
    used_numbers.append(numb)

print(sum)
