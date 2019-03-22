fn ReadFixedString bstream fixedLen =
(
	str = ""
	for i = 1 to fixedLen do
	(
		sStr = ReadByte bstream #unsigned
		if sStr != 0xFD and sStr != 0xFC do(
			str += bit.intAsChar sStr	  
		)
	)
	return str
)

fn ReadUInt bstream =
(
	return readLong bstream #unsigned
)