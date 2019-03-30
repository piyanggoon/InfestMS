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

-- 	Modify from "FBX to Biped 0.29"
-- 	(https://cafe.naver.com/pinksox/6064)
fn getBipedType node =
(
	types = #(
		#larm, #rarm,
		#lfingers, #rfingers,
		#lleg, #rleg,
		#ltoes, #rtoes,
		#spine, #tail, #head,
		#pelvis,
		#vertical, #horizontal,
		#turn,
		#footprints,
		#neck,
		#pony1, #pony2,
		#prop1, #prop2, #prop3,
		#lfArmTwist, #rfArmTwist,
		#lUparmTwist, #rUparmTwist,
		#lThighTwist, #rThighTwist,
		#lCalfTwist, #rCalfTwist,
		#lHorseTwist, #rHorseTwist			
	)

	if (classof node) != Biped_Object then
		return #(#notBiped, 0)

	for type in types do
	(
		for i = 1 to (biped.maxNumLinks node) do
		(
			try
			(
				if node == (biped.getNode node type link:i) then
					return #(type, i)
			)
			catch
			(
-- 				empty
			)
		)
	)

	return #(#xtra, 0)
)

fn findNodeByBip name =
(
	if (index = findString name "Biped01") then
	(
		str = replace name index 7 "Bip01"
		while (index = findString str " ") != undefined do
		(
			str = replace str index 1 "_"
		)
		return getNodeByName str
	)
	return undefined
)

fn findNodeByBone name =
(
	if (index = findString name "Bip01") then
	(
		str = replace name index 5 "Biped01"
		while (index = findString str "_") != undefined do
		(
			str = replace str index 1 " "
		)
		return getNodeByName str
	)
	return undefined
)

fn getLocalScaleXWorldPos node =
(
	scale = biped.getTransform node #scale
	matrix = matrix3 1
	matrix.pos = [scale.x, 0, 0]
	matrix *= node.transform
	return matrix.pos
)

fn getChildByScalePos node =
(
	if (classof node) != Biped_Object then
		return undefined

	if node.children.count == 0 then
		return undefined

	if node.children.count == 1 then
		return node.children[1]

	index = 0
	childDist = #()
	for i = 1 to node.children.count do
	(
		append childDist (distance node.children[i].transform.position (getLocalScaleXWorldPos node))
		minDist = amin childDist
		index = findItem childDist minDist
	)

	return node.children[index]
)

fn getFileByName folder name type =
(
	files = getFiles (folder + "\\*." + type)
	for file in files do
	(
		if (toLower name) == (toLower (filenameFromPath file)) then
		(
			return file
		)
		else if (toLower name) == (toLower (getFilenameFile file)) then
		(
			return file
		)
	)
	return undefined
)