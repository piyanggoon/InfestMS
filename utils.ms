fn ReadFixedString byteStream fixedLen =
(
	str = ""
	for i = 1 to fixedLen do
	(
		sStr = ReadByte byteStream #unsigned
		if sStr != 0xFD and sStr != 0xFC do
		(
			str += bit.intAsChar sStr	  
		)
	)
	return str
)

fn ReadUInt byteStream =
(
	return readLong byteStream #unsigned
)

fn point3Swap p1 = 
(
	p2 = Point3 0 0 0

	p2[1] = p1[1]
	p2[2] = p1[3]
	p2[3] = p1[2]

	return p2
)

fn maxtrix3Swap matrix =
(
	m = copy matrix
	r1 = m.row1
	r2 = m.row2
	r3 = m.row3
	r4 = m.row4

--  Z up Y
	c1 = Point4 r1[1] r2[1] r3[1] r4[1]
	c2 = Point4 r1[3] r2[3] r3[3] r4[3]
	c3 = Point4 r1[2] r2[2] r3[2] r4[2]

--  Row3 up Row2
	r1 = Point3 c1[1] c2[1] c3[1]
	r2 = Point3 c1[3] c2[3] c3[3]
	r3 = Point3 c1[2] c2[2] c3[2]
	r4 = Point3 c1[4] c2[4] c3[4]

	return matrix3 r1 r2 r3 r4
)