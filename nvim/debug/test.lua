

local foo = {
	bar = {
		baz = 1
	}
}

foo.bar.baz = 2

local function foobar()
	return foo
end

foobar()
