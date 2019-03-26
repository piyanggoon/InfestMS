struct scoVertex
(
	position,
	normal,
	tangent,
	vTangent,
	vColor
)

struct scoFace
(
	name,
	vIndices,
	v1 = #(0, 0),
	v2 = #(0, 0),
	v3 = #(0, 0)
)

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

struct wgtData
(
	boneID = #(0, 0, 0, 0),
	weight = #(0, 0, 0, 0)
)

struct anmFrame
(
	fQuaternion = #(0, 0, 0, 0),
	fPosition = #(0, 0, 0)
)

struct anmData
(
	name,
	flag,
	frame = #()
)