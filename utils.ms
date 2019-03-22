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