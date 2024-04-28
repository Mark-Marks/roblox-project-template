export type Left<L> = {
	tag: "left",
	value: L,
}

local function left<L>(value: L): Left<L>
	return {
		tag = "left",
		value = value,
	}
end

export type Right<R> = {
	tag: "right",
	value: R,
}

local function right<R>(value: R): Right<R>
	return {
		tag = "right",
		value = value,
	}
end

export type Either<L, R> = Left<L> | Right<R>

export type Some<T> = {
	tag: "some",
	value: T,
}

local function some<T>(value: T): Some<T>
	return {
		tag = "some",
		value = value,
	}
end

export type None = {
	tag: "none",
	value: nil,
}

local function none(): None
	return {
		tag = "none",
		value = nil,
	}
end

export type Option<T> = Some<T> | None

return {
	left = left,
	right = right,

	some = some,
	none = none,
}
