struct sklData
(
	name,
	parentID,
	fLength,
	c1 = #(0, 0, 0, 0),
	c2 = #(0, 0, 0, 0),
	c3 = #(0, 0, 0, 0)
)

struct sklMatrix
(
	_11, _21, _31, _41,
	_12, _22, _32, _42,
	_13, _23, _33, _43
)

struct sklBone
(
	name,
	parentID,
	fLength,
	matrix = #(),
	node
)